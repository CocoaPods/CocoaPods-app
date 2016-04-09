
import Cocoa

// `CPDocumentSourceDelegate` needs to be marked `@objc` to allow it to be used as an IBOutlet

@objc protocol CPDocumentSourceDelegate {
  func documentSourceDidUpdate(documentSource: CPDocumentSource, documents: [CPHomeWindowDocumentEntry])
}

// A base class for the document sources of the `CPSidebarDocumentsController`
class CPDocumentSource: NSObject {
  @IBOutlet weak var delegate: CPDocumentSourceDelegate?
  var documents : [CPHomeWindowDocumentEntry] { return [] }
}
