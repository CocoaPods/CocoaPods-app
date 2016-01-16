import Cocoa

class CPSidebarDocumentsController: NSObject {

  // This changes between Recent and Spotlight docs
  var currentSidebarItems = [CPHomeWindowDocumentEntry]()

  @IBOutlet weak var spotlightSource: CPSpotlightPodfileController!
  @IBOutlet weak var recentSource: CPRecentDocumentsController!

  @IBAction func recentButtonTapped(sender: AnyObject) {
    currentSidebarItems = recentSource.recentDocuments
  }

  @IBAction func spotlightButtonTapped(sender: AnyObject) {
    currentSidebarItems = spotlightSource.documents
  }
}
