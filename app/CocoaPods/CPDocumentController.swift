import Cocoa

// This subclass is required so that the app can broadcast notifications when document 
// based events occur, e.g. opening a document or updates to recently opened documents list.
// The base `NSDocumentController` class currently has no built-in notifications for these events.

class CPDocumentController: NSDocumentController {
  static let DocumentOpenedNotification = "CPDocumentControllerDocumentOpenedNotification"
  static let RecentDocumentUpdateNotification = "CPDocumentControllerRecentDocumentUpdateNotification"
  static let ClearRecentDocumentsNotification = "CPDocumentControllerClearRecentDocumentsNotification"
  
  var podInitController: CPPodfileInitController?
  var deintegrateController: CPDeintegrateController?
  
  // All of the `openDocument...` calls end up calling this one method, so adding our notification here is simple
  
  override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
    super.openDocument(withContentsOf: url, display: displayDocument) { (document, displayDocument, error) -> Void in
      if let _ = document { // Only fire the notification if we have a document
        NotificationCenter.default.post(name: Notification.Name(rawValue: CPDocumentController.DocumentOpenedNotification), object: self)
      }
      
      completionHandler(document, displayDocument, error)
    }
  }
  
  func selectXcodeproj(_ completion: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.allowedFileTypes = ["xcodeproj"]
    openPanel.begin { buttonIndex in
      guard buttonIndex == NSFileHandlingPanelOKButton else { completion(.none); return }
      guard let fileURL = openPanel.url else { completion(.none); return }
      completion(fileURL)
    }
  }

  override func newDocument(_ sender: Any?) {
    selectXcodeproj { fileURL in
      if let URL = fileURL {
        self.setupPodfile(URL)
      }
    }
  }

  func setupPodfile(_ xcodeprojURL: URL) {
    self.podInitController = CPPodfileInitController(xcodeprojURL: xcodeprojURL, completionHandler: { (podfileURL, error) in
      guard let podfileURL = podfileURL else {
        let alert = NSAlert(error: error! as NSError)
        alert.informativeText = error!.message
        alert.runModal()

        return
      }
      self.openDocument(withContentsOf: podfileURL, display: true) { _ in }
    })
  }

  @IBAction func removeCocoaPodsFromProject(_ sender: AnyObject?) {
    selectXcodeproj { fileURL in
      if let url = fileURL {
        self.deintegrateProject(url)
      }
    }
  }
  
  func deintegrateProject(_ xcodeprojURL: URL) {
    self.deintegrateController = CPDeintegrateController(xcodeprojURL: xcodeprojURL, completionHandler: { error in
      if let error = error {
        let alert = NSAlert(error: error as NSError)
        alert.informativeText = error.message
        alert.runModal()
      }
      else {
        let projectName = xcodeprojURL.lastPathComponent
        let localized = ~"POD_DEINTEGRATE_CONFIRMATION"
        let alert = NSAlert()
        alert.messageText = ~"POD_DEINTEGRATE_INFO"
        alert.informativeText = String.localizedStringWithFormat(localized, projectName)
        alert.runModal()
      }
    })
  }

  // `noteNewRecentDocument` ends up calling to this method so we can just override this one method
  
  override func noteNewRecentDocumentURL(_ url: URL) {
    super.noteNewRecentDocumentURL(url)
    
    NotificationCenter.default.post(name: Notification.Name(rawValue: CPDocumentController.RecentDocumentUpdateNotification), object: self)
  }
  
  override func clearRecentDocuments(_ sender: Any?) {
    super.clearRecentDocuments(sender)
    
    NotificationCenter.default.post(name: Notification.Name(rawValue: CPDocumentController.ClearRecentDocumentsNotification), object: self)
  }
}
