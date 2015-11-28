import Cocoa


protocol CPHiddenTabViewControllerDelegate {
  func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?)
}

class CPHiddenTabViewController: NSTabViewController {

  var hiddenTabDelegate: CPHiddenTabViewControllerDelegate?

  /// The docs lie, NSTabViewControllerTabStyle doesn't work
  /// with .Unspecified

  override func viewWillAppear() {
    super.viewWillAppear()
    tabView.tabViewType = .NoTabsNoBorder
  }

  // This is the only safe way to allow callbacks
  // when a tab has changed
  
  override func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
    hiddenTabDelegate?.tabView(tabView, didSelectTabViewItem: tabViewItem)
    super.tabView(tabView, didSelectTabViewItem: tabViewItem)
  }
}
