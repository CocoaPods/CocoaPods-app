import Cocoa

// We rely on configuration from another controller (the podfile view controller) to set the initial selected button.

class CPTabViewDelegate: NSObject, CPHiddenTabViewControllerDelegate {
  @objc dynamic var editorIsSelected = true
  @objc dynamic var infoIsSelected = false
  @objc dynamic var consoleIsSelected = false

  func tabView(_ tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {

    guard let identifier = tabViewItem?.identifier as? String else { return }

    editorIsSelected = identifier == "editor"
    infoIsSelected = identifier == "info"
    consoleIsSelected = identifier == "console"
  }
}
