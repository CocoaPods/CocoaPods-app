import Cocoa

class CPRecentDocumentSource: NSObject {

  var recentDocuments: [CPHomeWindowDocumentEntry] {
    let docs = NSDocumentController.sharedDocumentController()
    return docs.recentDocumentURLs.map { CPHomeWindowDocumentEntry(URL: $0) }
  }
  
}
