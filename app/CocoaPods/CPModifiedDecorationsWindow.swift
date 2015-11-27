//
//  CPModifiedDecorationsWindow.swift
//  CocoaPods
//
//  Created by Orta on 11/27/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa

class CPModifiedDecorationsWindow: NSWindow {

  /// We want to offset the window buttons to make them centered.
  /// To make the title bar fit we also use a hidden toolbar from interface builder

  override func makeKeyAndOrderFront(sender: AnyObject?) {

    appearance = NSAppearance(named:NSAppearanceNameVibrantLight)
    titlebarAppearsTransparent = true
    movableByWindowBackground = true
    titleVisibility = .Hidden

    let verticalOffset = 6
    [NSWindowButton.CloseButton, NSWindowButton.MiniaturizeButton, NSWindowButton.ZoomButton].forEach { type in
      guard let button = standardWindowButton(type) else { return }
      button.setFrameOrigin(NSMakePoint(button.frame.origin.x, button.frame.origin.y - CGFloat(verticalOffset)))
    }

    guard let button = standardWindowButton(.DocumentIconButton) else { return }
    button.setFrameOrigin(NSMakePoint(button.frame.origin.x, button.frame.origin.y - CGFloat(verticalOffset)))

    setFrame(NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - 1), display: true, animate: true)
    setFrame(NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + 1), display: true, animate: true)

    super.makeKeyAndOrderFront(sender)
  }

  override func setFrame(frameRect: NSRect, display flag: Bool) {
    super.setFrame(frameRect, display: flag)
  }
}
