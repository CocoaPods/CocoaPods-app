import Cocoa

class CPPodfileConsoleViewController: NSViewController, NSTextViewDelegate {
  @IBOutlet var textView: NSTextView!
  @IBOutlet weak var hintButton: NSButton!

  dynamic var editable = false // the textview in the storyboard is bound to this
    
  override func viewDidLoad() {
    super.viewDidLoad()

    let settings = CPFontAndColourGateKeeper()
    textView.font = settings.defaultFont
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    guard let podfileVC = podfileViewController, project = podfileVC.userProject else {
      return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }
    
    if textView.string!.isEmpty {
      hintButton.hidden = false
      if project.contents.isEmpty {
        updateHintButton(imageNamed: "emptyPodfile", title: NSLocalizedString("PODFILE_WINDOW_CONSOLE_HINT_EMPTY_PODFILE", comment: ""))
      } else if project.syntaxErrors.count > 0 {
        updateHintButton(imageNamed: "errorPodfile", title: NSLocalizedString("PODFILE_WINDOW_CONSOLE_HINT_ERROR_PODFILE", comment: ""))
      } else {
        updateHintButton(imageNamed: "compiledPodfile", title: NSLocalizedString("PODFILE_WINDOW_CONSOLE_HINT_READY_PODFILE", comment: ""))
      }
    } else {
      hintButton.hidden = true
    }
  }
  
  // MARK: - Hints
    
  func updateHintButton(imageNamed imageNamed: String, title: String) {
    hintButton.image = NSImage(named: imageNamed)
    hintButton.alternateImage = NSImage(named: "\(imageNamed)_selected")
    hintButton.attributedTitle = NSAttributedString(title, color: NSColor.ansiMutedWhite(), font: NSFont.labelFontOfSize(13), alignment: .Center)
    hintButton.attributedAlternateTitle = NSAttributedString(title, color: NSColor.ansiBrightWhite(), font: NSFont.labelFontOfSize(13), alignment: .Center)
  }
  
  @IBAction func hintButton(sender: AnyObject) {
    guard let podfileVC = podfileViewController, project = podfileVC.userProject else {
        return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }
    
    if project.contents.isEmpty {
        let externalLinksHelper = CPExternalLinksHelper()
        externalLinksHelper.openSearch(sender)
    } else if project.syntaxErrors.count > 0 {
      podfileVC.showEditorTab(sender)
    } else {
      hintButton.hidden = true
      podfileVC.install(sender)
    }
  }
  
  // MARK: - TextView
  
  func textView(textView: NSTextView, willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue], toCharacterRanges newSelectedCharRanges: [NSValue]) -> [NSValue] {

    // Determine if we're at the tail of the output log (and should scroll) before we append more to it.

    guard let scrollView = textView.enclosingScrollView else { return newSelectedCharRanges }

    let visibleRect = scrollView.documentVisibleRect
    let maxContentOffset = textView.bounds.size.height - visibleRect.size.height
    let scrolledToBottom = visibleRect.origin.y == maxContentOffset

    // Keep the text view at the bottom if it was previously, otherwise restore the previous position.

    if (scrolledToBottom) {
      textView.scrollToEndOfDocument(self)
    } else {
      textView.scrollPoint(visibleRect.origin)
    }

    return newSelectedCharRanges
  }

}
