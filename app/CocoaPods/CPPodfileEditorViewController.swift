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

  @IBAction func commentSelection(sender: NSMenuItem) {
    let selection = selectedLines(editor.textView)
    let processed = commentsInSelection(selection) ? removeCommentsFromLines(selection) : addCommentsInLines(selection)
    // New line required
    let newText = "\(processed.joinWithSeparator("\n"))\n"

    editor.textView.textStorage?.replaceCharactersInRange(selectedLinesRange(editor.textView), withString: newText)
  }

}

/// Implements methods to toggle comments in the Podfile

typealias Commenting = CPPodfileEditorViewController
extension Commenting {

  /// Checks wether the selection consists of solely comments
  /// - parameter selection: an array of strings representing the user's selection
  /// - returns: Bool

  func commentsInSelection(selection: [String]) -> Bool {
    let regex = try! NSRegularExpression(pattern: "\\s*#\\s*", options: .CaseInsensitive)

    return selection.reduce(true) { (all, line) -> Bool in
      return regex.matchesInString(line, options: .Anchored, range: NSMakeRange(0, line.characters.count)).count > 0 && all
    }
  }

  /// Removes the comment syntax from the selection. 
  ///
  /// Removes '# ' and '#' occurences from the start of the lines
  /// - parameter lines: an array of strings representing the user's selection
  /// - returns: [String]

  func removeCommentsFromLines(lines: [String]) -> [String] {
    let comment = try! NSRegularExpression(pattern: "#\\s?", options: .CaseInsensitive)
    return lines.map { line in
      let firstMatch = comment.rangeOfFirstMatchInString(line, options: .Anchored, range: NSMakeRange(0, line.characters.count))
      return (line as NSString).stringByReplacingCharactersInRange(firstMatch, withString: "")
    }
  }

  /// Adds the comment syntax to the selected text
  ///
  /// Adds '# ' at the start of each line
  /// - parameter lines: an array of strings representing the user's selection
  /// - returns: [String]

  func addCommentsInLines(lines: [String]) -> [String] {
    return lines.map { line in
      return line.stringByReplacingCharactersInRange(Range(start: line.startIndex, end: line.startIndex), withString: "# ")
    }
  }

}

/// Implements methods to retrieve the selected text from a NSTextView

typealias EditorSelection = CPPodfileEditorViewController
extension EditorSelection {

  /// Returns the selected lines of text as an array of strings
  ///
  /// - parameter textView: the `NSTextView` containing the selection
  /// - returns: [String]

  func selectedLines(textView: NSTextView) -> [String] {
    guard let selection = selectedText(textView) where selection.characters.count > 0 else { return [] }

    // The substring is required to filter out the empty last line returned otherwise
    return selection.substringToIndex(selection.endIndex.predecessor()).componentsSeparatedByString("\n")
  }

  /// Returns the selected text
  ///
  /// - parameter textView: the `NSTextView` containing the selection
  /// - returns: String?

  func selectedText(textView: NSTextView) -> String? {
    guard let text = textView.string else { return .None }

    return (text as NSString).substringWithRange(selectedLinesRange(textView))
  }

  /// Returns the selected text's range
  ///
  /// - parameter textView: the `NSTextView` containing the selection
  /// - returns: NSRange

  func selectedLinesRange(textView: NSTextView) -> NSRange {
    guard let text = textView.string else { return NSMakeRange(0, 0) }

    return (text as NSString).lineRangeForRange(editor.textView.selectedRange())
  }

}
