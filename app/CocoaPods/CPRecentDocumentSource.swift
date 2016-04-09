import Cocoa

/// Not much going on, just provides recent documents
/// note: is not memoized.

class CPRecentDocumentSource: CPDocumentSource {
  
  override var documents: [CPHomeWindowDocumentEntry] {
    get {
      let docs = NSDocumentController.sharedDocumentController()
      return docs.recentDocumentURLs.map { CPHomeWindowDocumentEntry(URL: $0) }
    }
  }
  
  override init() {
    super.init()
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: #selector(updateRecentDocuments(_:)), name: CPDocumentController.ClearRecentDocumentsNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(updateRecentDocuments(_:)), name: CPDocumentController.RecentDocumentUpdateNotification, object: nil)
  }
  
  deinit {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver(self, name: CPDocumentController.ClearRecentDocumentsNotification, object: nil)
    notificationCenter.removeObserver(self, name: CPDocumentController.RecentDocumentUpdateNotification, object: nil)
  }
  
  func updateRecentDocuments(notification: NSNotification) {
    self.delegate?.documentSourceDidUpdate(self, documents: documents)
  }
}
