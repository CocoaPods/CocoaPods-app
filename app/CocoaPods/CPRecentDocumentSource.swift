import Cocoa

/// Not much going on, just provides recent documents
/// note: is not memoized.

class CPRecentDocumentSource: NSObject {

  var recentDocuments: [CPHomeWindowDocumentEntry] {
    let docs = NSDocumentController.sharedDocumentController()
    return docs.recentDocumentURLs.map { CPHomeWindowDocumentEntry(URL: $0) }
  }
  
}
