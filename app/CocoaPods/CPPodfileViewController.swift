//
//  CPPodfileViewController.swift
//  CocoaPods
//
//  Created by Orta on 11/15/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa

/// UIVIewController to represent the Podfile editor
/// It's scope is keeping track of the user project,
/// handling / exposing tabs and providing a central
/// access place for mutable state within the Podfile
/// section of CocoaPods.app

class CPPodfileViewController: NSViewController {

  var userProject:CPUserProject!
  @IBOutlet var contentView:NSView!

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let storyboard = self.storyboard else {
      return print("This VC needs a storyboard to set itself up.")
    }

    guard let tabController = storyboard.instantiateControllerWithIdentifier("Podfile Content Tab Controller") as? NSTabViewController else {
      return print("Could not get the Content Tab View Controller")
    }

    addChildViewController(tabController)
    tabController.view.frame = contentView.bounds
    contentView.addSubview(tabController.view)

    let left   = NSLayoutConstraint(item: tabController.view, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 0)
    let right  = NSLayoutConstraint(item: tabController.view, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: 0)
    let top    = NSLayoutConstraint(item: tabController.view, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0)
    let bottom = NSLayoutConstraint(item: tabController.view, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0)

    // TODO: Why does this not let the window resize?
    contentView.addConstraints([left, right, top, bottom])
  }
    
}
