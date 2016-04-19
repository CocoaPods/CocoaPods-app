import Cocoa

/// Listens for the change in the key window and toggles
/// the build / editor menu items  when there is a 
/// NSDocument attatched to the window.

class CPMenuVisiblityDirector: NSObject {

  @IBOutlet weak var editorMenu: NSMenuItem!
  @IBOutlet weak var buildMenu: NSMenuItem!

  /// An array of the menu items to show/hide
  var podfileEditorMenuItems: [NSMenuItem] {
    return [editorMenu, buildMenu]
  }

  /// Setup notifications
  override func awakeFromNib() {
    let notificationCenter = NSNotificationCenter.defaultCenter()

    notificationCenter.addObserver(self, selector: #selector(windowsChanged(_:)), name: NSWindowDidBecomeKeyNotification, object: nil)
  }

  /// Set hidden on the menus when we don't need to enable the submenus
  func windowsChanged(notification: NSNotification) {
    guard let window = notification.object as? NSWindow else { return print("Notification does not have a window") }
    let docs = NSDocumentController.sharedDocumentController()
    let windowHasDocument = docs.documentForWindow(window) != nil

    for menu in podfileEditorMenuItems {
      menu.enabled = windowHasDocument
    }
  }
}
