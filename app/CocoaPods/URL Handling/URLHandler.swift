import Foundation

/// Registers and handles the events related to opening the App via a custom URL.
class URLHandler: NSObject {
  
  /// Registers itself has the handler for the URL events.
  func registerHandler() {
    
    let eventClass = AEEventClass(kInternetEventClass)
    let eventId = AEEventID(kAEGetURL)
    
    let manager = NSAppleEventManager.sharedAppleEventManager()
    manager.setEventHandler(
      self,
      andSelector: #selector(handleEvent(_:withReply:)),
      forEventClass: eventClass,
      andEventID: eventId
    )
  }
  
  func handleEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
    let key = AEKeyword(keyDirectObject)
    let url = event.paramDescriptorForKeyword(key)?.stringValue
    print("Handled URL: \(url)", terminator: "")
  }
  
}

