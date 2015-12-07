import Cocoa

class CPTabViewDelegate: NSObject, CPHiddenTabViewControllerDelegate {
  dynamic var editorIsSelected = true // By default, the editor is selected
  dynamic var infoIsSelected = false
  dynamic var consoleIsSelected = false

  func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {

    guard let identifier = tabViewItem?.identifier as? String else { return }

    editorIsSelected = identifier == "editor"
    infoIsSelected = identifier == "info"
    consoleIsSelected = identifier == "console"
  }
}
