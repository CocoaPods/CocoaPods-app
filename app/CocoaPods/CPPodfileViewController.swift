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

/// TODO:
///  setting tabs via the images
///  cmd + 1,2,3
///  add commands for `pod install` / `update`


class CPPodfileViewController: NSViewController {

  var userProject:CPUserProject!
  @IBOutlet var contentView:NSView!
  dynamic var installAction: CPInstallAction!

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

    // This just aligns the contentview at 0 to all edges
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":tabController.view]))
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":tabController.view]))
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    // This is DI'd in after viewDidLoad
    installAction = CPInstallAction(userProject: userProject)
  }

  @IBAction func install(obj: AnyObject) {
    // switch tabs
    installAction.performAction(.Install(verbose: false))
  }

}

extension NSViewController {

  /// Recurse the parentViewControllers till we find a CPPodfileViewController
  var podfileViewController: CPPodfileViewController? {

    guard let parent = self.parentViewController else { return nil }
    if let appVC = parent as? CPPodfileViewController {
      return appVC
    } else {
      return parent.podfileViewController
    }
  }
}