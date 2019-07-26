import Cocoa

class CPPodfileConsoleViewController: NSViewController, NSTextViewDelegate {
  @IBOutlet var textView: NSTextView!
  @IBOutlet weak var hintButton: NSButton!

  @objc dynamic var editable = false // the textview in the storyboard is bound to this
    
  override func viewDidLoad() {
    super.viewDidLoad()

    let settings = CPFontAndColourGateKeeper()
    textView.font = settings.defaultFont
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    guard let podfileVC = podfileViewController, let project = podfileVC.userProject else {
      return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }
    
    if textView.string.isEmpty {
      hintButton.isHidden = false
      if let podfileErrorState = CPPodfileErrorState(fromProject: project) {
        switch podfileErrorState {
        case .emptyFile:
          updateHintButton(imageNamed: "emptyPodfile", title: ~"PODFILE_WINDOW_CONSOLE_HINT_EMPTY_PODFILE")
        case .syntaxError:
          updateHintButton(imageNamed: "errorPodfile", title: ~"PODFILE_WINDOW_CONSOLE_HINT_ERROR_PODFILE")
        }
      } else {
        updateHintButton(imageNamed: "compiledPodfile", title: ~"PODFILE_WINDOW_CONSOLE_HINT_READY_PODFILE")
      }
    } else {
      hintButton.isHidden = true
    }
  }
  
  // MARK: - Hints
    
  func updateHintButton(imageNamed: String, title: String) {
    hintButton.image = NSImage(named: NSImage.Name(rawValue: imageNamed))
    hintButton.alternateImage = NSImage(named: NSImage.Name(rawValue: "\(imageNamed)_selected"))
    hintButton.attributedTitle = NSAttributedString(title, color: NSColor.ansiMutedWhite(), font: NSFont.labelFont(ofSize: 13), alignment: .center)
    hintButton.attributedAlternateTitle = NSAttributedString(title, color: NSColor.ansiBrightWhite(), font: NSFont.labelFont(ofSize: 13), alignment: .center)
  }
  
  @IBAction func hintButton(_ sender: AnyObject) {
    guard let podfileVC = podfileViewController, let project = podfileVC.userProject else {
        return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }
    
    if let podfileErrorState = CPPodfileErrorState(fromProject: project) {
      switch podfileErrorState {
      case .emptyFile:
        let externalLinksHelper = CPExternalLinksHelper()
        externalLinksHelper.openSearch(sender)
        
      case .syntaxError:
        podfileVC.showEditorTab(sender)
      }
    } else {
      hintButton.isHidden = true
      podfileVC.install(sender)
    }
  }
  
  // MARK: - TextView
  
  func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue], toCharacterRanges newSelectedCharRanges: [NSValue]) -> [NSValue] {

    // Determine if we're at the tail of the output log (and should scroll) before we append more to it.

    guard let scrollView = textView.enclosingScrollView else { return newSelectedCharRanges }

    let visibleRect = scrollView.documentVisibleRect
    let maxContentOffset = textView.bounds.size.height - visibleRect.size.height
    let scrolledToBottom = visibleRect.origin.y == maxContentOffset

    // Keep the text view at the bottom if it was previously, otherwise restore the previous position.

    if (scrolledToBottom) {
      textView.scrollToEndOfDocument(self)
    } else {
      textView.scroll(visibleRect.origin)
    }

    return newSelectedCharRanges
  }

}
