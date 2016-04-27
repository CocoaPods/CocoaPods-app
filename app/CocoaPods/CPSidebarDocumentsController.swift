import Cocoa

class CPSidebarDocumentsController: NSObject, CPDocumentSourceDelegate {

  // This changes between Recent and Spotlight docs
  dynamic var currentSidebarItems = [CPHomeWindowDocumentEntry]()

  // for bindings to show a progress during spotlight metadata
  // searching
  dynamic var loading = false

  @IBOutlet weak var recentButton: CPHomeSidebarButton!
  @IBOutlet weak var spotlightButton: CPHomeSidebarButton!

  var buttons: [CPHomeSidebarButton] { return [recentButton, spotlightButton] }

  @IBOutlet weak var spotlightSource: CPSpotlightDocumentSource!
  @IBOutlet weak var recentSource: CPRecentDocumentSource!

  // When we load up, determine if there are any recent docs
  // as this is synchronous + fast, we can switch to spotlight
  // if we get nothing from them.

  // Triggering this will very likely cause it to go into 
  // the `source.documents.isEmpty?` if statment

  override func awakeFromNib() {
    if recentSource.documents.count > 0 {
      recentButtonTapped(recentButton)
    } else {
      spotlightButtonTapped(spotlightButton)
    }
  }
  
  func documentSourceDidUpdate(documentSource: CPDocumentSource, documents: [CPHomeWindowDocumentEntry]) {
    
    // Check the document source is the currently selected by checking the related button's state
    // If it is selected, then update `currentSidebarItems` with the documents
    
    switch documentSource {
      case recentSource:
        recentButton.userInteractionEnabled = !documents.isEmpty // If recentSource has no data, then disable the button
        
        if (recentButton.state == NSOnState) {
          if documents.count > 0 {
            recentButtonTapped(recentButton)
          } else {
            spotlightButtonTapped(spotlightButton)
          }
        }
      
      case spotlightSource where spotlightButton.state == NSOnState:
        loading = false
        if documents.isEmpty {
          showPopoverForOpenPodfile()
        } else {
          // Re-run the press now there's content
          spotlightButtonTapped(spotlightButton)
        }
      
      default:
        break
      }
  }

  @IBAction func recentButtonTapped(sender: CPHomeSidebarButton) {
    currentSidebarItems = recentSource.documents
    selectButton(sender)
  }

  @IBAction func spotlightButtonTapped(sender: CPHomeSidebarButton) {
    let source = spotlightSource
    currentSidebarItems = source.documents
    selectButton(sender)

    // Could either be no podfiles
    // on the users computer - or still searching
    // in which case we wait for the delegate
    
    if source.documents.isEmpty {
      loading = true
    }
    
    // By checking if we have recent documents on spotlight tap, we can minimise code reuse of this line 
    // as whenever we load Spotlight we should disable `recentButton` if recent documents is empty
    recentButton.userInteractionEnabled = !recentSource.documents.isEmpty
  }

  // When there are no Podfiles in spotlight
  // Then we should have a call to action that tells
  // someone what we want to show.

  @IBOutlet weak var openPodfileView: NSView!
  @IBOutlet weak var documentScrollView: NSScrollView!
  func showPopoverForOpenPodfile() {

    // Setup the title for the button
    let title = ~"MAIN_WINDOW_OPEN_DOCUMENT_BUTTON_TITLE"
    let buttonTitle = NSAttributedString.init(title, color: .ansiMutedWhite(), font: .labelFontOfSize(13), alignment: .Center)
    let altButtonTitle = NSAttributedString.init(title, color: .ansiBrightWhite(), font: .labelFontOfSize(13), alignment: .Center)

    for case let button as NSButton in openPodfileView.subviews {
      button.attributedTitle = buttonTitle
      button.attributedAlternateTitle = altButtonTitle
    }

    // Replace the tableview with our "Open Podfile" button
    documentScrollView.hidden = true
    openPodfileView.frame = documentScrollView.frame
    documentScrollView.superview?.addSubview(openPodfileView)

    // Make sure that you can't change the doc types (it will do nothing)
    buttons.forEach {
      self.setButton($0, state: NSOffState)
      $0.userInteractionEnabled = false
    }
  }

  func selectButton(button: CPHomeSidebarButton) {
    setButton(button, state: NSOnState)
    
    let otherButtons = buttons.filter { $0 != button }
    otherButtons.forEach { self.setButton($0, state: NSOffState) }
  }

  func setButton(button: CPHomeSidebarButton, state: Int) {
//    button.bordered = select
    button.state = state // Using NSOnState/NSOffState to signify the state of the button
    button.userInteractionEnabled = (state != NSOnState)
  }
}
