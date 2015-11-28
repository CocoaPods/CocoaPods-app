import Cocoa
import Fragaria

/// The Editor's role is to show our Fragaria editor
/// and ensure the changes are sent back upstream to the 
/// CPPodfileViewController's CPUserProject

class CPPodfileEditorViewController: NSViewController, NSTextViewDelegate {

  @IBOutlet var editor: MGSFragariaView!
  var syntaxChecker: CPPodfileReflection!

  // As the userProject is DI'd into the PodfileVC
  // it occurs after the view is set up.

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let podfileVC = podfileViewController, project = podfileVC.userProject else {
      return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }

    editor.syntaxColoured = true
    editor.syntaxDefinitionName = "Podfile"
    editor.string = project.contents

    let settings = CPFontAndColourGateKeeper()
    editor.textFont = settings.defaultFont
    editor.colourForNumbers = settings.cpGreen
    editor.colourForStrings = settings.cpRed
    editor.colourForComments = settings.cpBrightBrown
    editor.colourForKeywords = settings.cpBlue
    editor.colourForVariables = settings.cpGreen
    editor.colourForInstructions = settings.cpBrightMagenta

    project.undoManager = editor.textView.undoManager
    
    syntaxChecker = CPPodfileReflection(podfileEditorVC: self, fragariaEditor: editor)
    syntaxChecker.textDidChange(NSNotification(name: "", object: nil))
  }

  func textDidChange(notification: NSNotification) {
    guard let textView = notification.object as? NSTextView,
      let podfileVC = podfileViewController else { return }

    podfileVC.userProject.contents = textView.string

    // Passing the message on to the syntax checker
    syntaxChecker.textDidChange(notification)
  }
}
