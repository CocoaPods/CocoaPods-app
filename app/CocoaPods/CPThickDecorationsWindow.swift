import Cocoa

/// Thick banded window - used in then Home window

class CPThickDecorationsWindow: NSWindow {

  /// We want to offset the window buttons to make them centered.

  override func makeKeyAndOrderFront(sender: AnyObject?) {

    titlebarAppearsTransparent = true
    movableByWindowBackground = true
    titleVisibility = .Hidden

    super.makeKeyAndOrderFront(sender)

    [NSWindowDidResizeNotification, NSWindowDidResizeNotification, NSWindowDidMoveNotification].forEach { notification in
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveWindowButtons), name: notification, object: self)
    }
    moveWindowButtons()
  }

  func moveWindowButtons(){
    let verticalOffset = 12

    [NSWindowButton.CloseButton, NSWindowButton.MiniaturizeButton, NSWindowButton.ZoomButton].forEach { type in
      guard let button = standardWindowButton(type) else { return }
      button.setFrameOrigin(NSMakePoint(button.frame.origin.x, CGFloat(verticalOffset)))
    }
  }
}
