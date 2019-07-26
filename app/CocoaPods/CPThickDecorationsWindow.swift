import Cocoa

/// Thick banded window - used in the Home window

class CPThickDecorationsWindow: NSWindow {

  /// We want to offset the window buttons to make them centered.

  override func makeKeyAndOrderFront(_ sender: Any?) {
    titlebarAppearsTransparent = true
    isMovableByWindowBackground = true
    titleVisibility = .hidden

    super.makeKeyAndOrderFront(sender)

    [NSWindow.didResizeNotification, NSWindow.didMoveNotification].forEach { notification in
      NotificationCenter.default.addObserver(self, selector: #selector(moveWindowButtons), name: notification, object: self)
    }
    moveWindowButtons()
  }

  @objc func moveWindowButtons(){
    let verticalOffset: CGFloat = 12

    ([.closeButton, .miniaturizeButton, .zoomButton] as [NSWindow.ButtonType]).forEach { type in
      guard let button = standardWindowButton(type) else { return }
      button.setFrameOrigin(NSMakePoint(button.frame.origin.x, verticalOffset))
    }
  }
}
