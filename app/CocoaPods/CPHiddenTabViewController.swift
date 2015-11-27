//
//  CPHiddenTabViewController.swift
//  CocoaPods
//
//  Created by Orta on 11/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa

/// The docs lie, NSTabViewControllerTabStyle doesn't work
/// with .Unspecified

class CPHiddenTabViewController: NSTabViewController {

  override func viewWillAppear() {
    super.viewWillAppear()
    tabView.tabViewType = .NoTabsNoBorder
  }
}
