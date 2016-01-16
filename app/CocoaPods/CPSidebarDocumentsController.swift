import Cocoa

class CPSidebarDocumentsController: NSObject {

  // This changes between Recent and Spotlight docs
  dynamic var currentSidebarItems = [CPHomeWindowDocumentEntry]()

  // for bindings to show a progress during spotlight metadata
  // searching
  dynamic var loading = false

  @IBOutlet weak var recentButton: NSButton!
  @IBOutlet weak var spotlightButton: NSButton!

  var buttons :[NSButton] { return [recentButton, spotlightButton] }

  @IBOutlet weak var spotlightSource: CPSpotlightDocumentSource!
  @IBOutlet weak var recentSource: CPRecentDocumentSource!

  override func awakeFromNib() {
    if recentSource.recentDocuments.count > 0 {
      recentButtonTapped(recentButton)
    } else {
      spotlightButtonTapped(spotlightButton)
    }
  }

  @IBAction func recentButtonTapped(sender: NSButton) {
    currentSidebarItems = recentSource.recentDocuments
    deselectButton(sender)
  }

  @IBAction func spotlightButtonTapped(sender: NSButton) {
    let source = spotlightSource
    currentSidebarItems = source.documents
    deselectButton(sender)

    // Could either be no podfiles
    // on the users computer - or still searching
    // in which case we use the promise to know
    // for sure

    if source.documents.isEmpty {

      spotlightSource.completedPromise.addBlock {
        let stillSelectedSpotlight = !sender.enabled
        if !stillSelectedSpotlight { return }

        if source.documents.isEmpty {
          self.showPopoverForOpenPodfile()
        } else {

          // Re-run the press now there's content
          self.spotlightButtonTapped(sender)
        }
      }
    }
  }

  func showPopoverForOpenPodfile() {

  }

  func deselectButton(button:NSButton) {
    button.bordered = true
    button.enabled = false

    let otherButtons = buttons.filter { $0 != button }
    otherButtons.forEach { (button) in
      button.bordered = false
      button.enabled = true
    }
  }
}
