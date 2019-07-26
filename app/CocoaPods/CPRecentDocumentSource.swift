import Cocoa

/// Not much going on, just provides recent documents
/// note: is not memoized.

class CPRecentDocumentSource: CPDocumentSource {
  
  override var documents: [CPHomeWindowDocumentEntry] {
    get {
      let docs = NSDocumentController.shared
      return docs.recentDocumentURLs.map { CPHomeWindowDocumentEntry(url: $0) }
    }
  }
  
  override init() {
    super.init()
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(updateRecentDocuments(_:)), name: NSNotification.Name(rawValue: CPDocumentController.ClearRecentDocumentsNotification), object: nil)
    notificationCenter.addObserver(self, selector: #selector(updateRecentDocuments(_:)), name: NSNotification.Name(rawValue: CPDocumentController.RecentDocumentUpdateNotification), object: nil)
  }
  
  deinit {
    let notificationCenter = NotificationCenter.default
    notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: CPDocumentController.ClearRecentDocumentsNotification), object: nil)
    notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: CPDocumentController.RecentDocumentUpdateNotification), object: nil)
  }
  
  @objc func updateRecentDocuments(_ notification: Notification) {
    self.delegate?.documentSourceDidUpdate(self, documents: documents)
  }
}
