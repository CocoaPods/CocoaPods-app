import Cocoa

class CPModifiedDecorationsWindow: NSWindow {

  var documentIconButton: NSButton?

  /// We want to offset the window buttons to make them centered.
  /// To make the title bar fit we also use a hidden toolbar from interface builder

  override func makeKeyAndOrderFront(_ sender: Any?) {

    appearance = NSAppearance(named:NSAppearanceNameVibrantLight)
    titlebarAppearsTransparent = true
    isMovableByWindowBackground = true

    // Confusing? Yes
    // So: I couldn't find a way to move the titlebar items if you show the document title,
    //     instead we keep track of the button and provide it as a property on the window,
    //     then it can be placed inside the view heirarchy.
    documentIconButton = standardWindowButton(.documentIconButton)

    titleVisibility = .hidden
    super.makeKeyAndOrderFront(sender)

    [NSNotification.Name.NSWindowDidResize, NSNotification.Name.NSWindowDidResize, NSNotification.Name.NSWindowDidMove].forEach { notification in
        NotificationCenter.default.addObserver(self, selector: #selector(moveWindowButtons), name: notification, object: self)
    }
    moveWindowButtons()
  }

  func moveWindowButtons(){
    let verticalOffset = 6

    [NSWindowButton.closeButton, NSWindowButton.miniaturizeButton, NSWindowButton.zoomButton].forEach { type in
        guard let button = standardWindowButton(type) else { return }
        button.setFrameOrigin(NSMakePoint(button.frame.origin.x, CGFloat(verticalOffset)))
    }
  }
}
