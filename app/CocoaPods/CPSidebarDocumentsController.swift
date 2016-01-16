import Cocoa

class CPSidebarDocumentsController: NSObject {

  // This changes between Recent and Spotlight docs
  dynamic var currentSidebarItems = [CPHomeWindowDocumentEntry]()


  @IBOutlet weak var recentButton: NSButton!
  @IBOutlet weak var spotlightButton: NSButton!

  var buttons :[NSButton] { return [recentButton, spotlightButton] }

  @IBOutlet weak var spotlightSource: CPSpotlightPodfileController!
  @IBOutlet weak var recentSource: CPRecentDocumentsController!

  @IBAction func recentButtonTapped(sender: NSButton) {
    currentSidebarItems = recentSource.recentDocuments
    deselectButton(sender)
  }

  @IBAction func spotlightButtonTapped(sender: NSButton) {
    currentSidebarItems = spotlightSource.documents
    deselectButton(sender)
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
