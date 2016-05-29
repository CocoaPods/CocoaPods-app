import Cocoa

/// Thick banded window - used in the Home window

class CPThickDecorationsWindow: NSWindow {

  /// We want to offset the window buttons to make them centered.

  override func makeKeyAndOrderFront(sender: AnyObject?) {
    titlebarAppearsTransparent = true
    movableByWindowBackground = true
    titleVisibility = .Hidden

    super.makeKeyAndOrderFront(sender)

    [NSWindowDidResizeNotification, NSWindowDidMoveNotification].forEach { notification in
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveWindowButtons), name: notification, object: self)
    }
    moveWindowButtons()
  }

  func moveWindowButtons(){
    let verticalOffset: CGFloat = 12

    ([.CloseButton, .MiniaturizeButton, .ZoomButton] as [NSWindowButton]).forEach { type in
      guard let button = standardWindowButton(type) else { return }
      button.setFrameOrigin(NSMakePoint(button.frame.origin.x, verticalOffset))
    }
  }
}
