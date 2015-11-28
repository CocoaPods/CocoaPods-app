//
//  CPReturnTriggeringTableView.swift
//  CocoaPods
//
//  Created by Orta on 11/27/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa

/// We want to have return trigger the double click 
/// action on a cell.

class CPReturnTriggeringTableView: NSTableView {

  override func keyDown(event: NSEvent) {
    let returnKeycode = 36

    if Int(event.keyCode) == returnKeycode {
      sendAction(doubleAction, to: target)
      return
    }

    super.keyDown(event)
  }

}
