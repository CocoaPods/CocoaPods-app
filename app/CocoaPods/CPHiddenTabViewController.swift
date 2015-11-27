//
//  CPHiddenTabViewController.swift
//  CocoaPods
//
//  Created by Orta on 11/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa

class CPHiddenTabViewController: NSTabViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    for subview in view.subviews where subview as? NSSegmentedControl != nil {
      subview.hidden = true
    }
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    let tabs = view.subviews.filter { $0.isKindOfClass(NSTabView) }
    guard let tab = tabs.first else { return }
    tab.frame = tab.superview!.bounds
  }

  override func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
    super.tabView(tabView, didSelectTabViewItem: tabViewItem)

    self.viewWillLayout()
  }

}
