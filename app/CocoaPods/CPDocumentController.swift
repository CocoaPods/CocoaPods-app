import Cocoa

// This subclass is required so that the app can broadcast notifications when document 
// based events occur, e.g. opening a document or updates to recently opened documents list.
// The base `NSDocumentController` class currently has no built-in notifications for these events.

class CPDocumentController: NSDocumentController {
  static let DocumentOpenedNotification = "CPDocumentControllerDocumentOpenedNotification"
  static let RecentDocumentUpdateNotification = "CPDocumentControllerRecentDocumentUpdateNotification"
  static let ClearRecentDocumentsNotification = "CPDocumentControllerClearRecentDocumentsNotification"
  
  var podInitController: CPPodfileInitController?
  
  // All of the `openDocument...` calls end up calling this one method, so adding our notification here is simple
  
  override func openDocumentWithContentsOfURL(url: NSURL, display displayDocument: Bool, completionHandler: (NSDocument?, Bool, NSError?) -> Void) {
    super.openDocumentWithContentsOfURL(url, display: displayDocument) { (document, displayDocument, error) -> Void in
      if let _ = document { // Only fire the notification if we have a document
        NSNotificationCenter.defaultCenter().postNotificationName(CPDocumentController.DocumentOpenedNotification, object: self)
      }
      
      completionHandler(document, displayDocument, error)
    }
  }
  
  override func newDocument(sender: AnyObject?) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.allowedFileTypes = ["xcodeproj"]
    
    openPanel.beginWithCompletionHandler { buttonIndex in
      guard buttonIndex == NSFileHandlingPanelOKButton else { return }
      guard let fileURL = openPanel.URL else { return }
      
      self.podInitController = CPPodfileInitController(xcodeprojURL: fileURL, completionHandler: { podfileURL, error -> () in
        guard let podfileURL = podfileURL else {
          let alert = NSAlert(error: error! as NSError)
          alert.informativeText = error!.message
          alert.runModal()
          
          return
        }
        self.openDocumentWithContentsOfURL(podfileURL, display: true) { _ in }
      })
    }
  }
  
  // `noteNewRecentDocument` ends up calling to this method so we can just override this one method
  
  override func noteNewRecentDocumentURL(url: NSURL) {
    super.noteNewRecentDocumentURL(url)
    
    NSNotificationCenter.defaultCenter().postNotificationName(CPDocumentController.RecentDocumentUpdateNotification, object: self)
  }
  
  override func clearRecentDocuments(sender: AnyObject?) {
    super.clearRecentDocuments(sender)
    
    NSNotificationCenter.defaultCenter().postNotificationName(CPDocumentController.ClearRecentDocumentsNotification, object: self)
  }
}
