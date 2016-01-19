import Cocoa

class TransparentWhiteView: NSView {
  override func drawRect(dirtyRect: NSRect) {
    NSColor(calibratedWhite: 1, alpha: 0.3).set()
    NSRectFill(dirtyRect);
  }
}

class TransparentBrownView: NSView {
  override func drawRect(dirtyRect: NSRect) {
    NSColor(colorLiteralRed: 56/256, green: 1/256, blue: 0, alpha: 0.6).set()
    NSRectFill(dirtyRect);
  }
}

class BrownView: NSView {
  override func drawRect(dirtyRect: NSRect) {
    NSColor(colorLiteralRed: 56/256, green: 1/256, blue: 0, alpha: 1).set()
    NSRectFill(dirtyRect);
  }
}

class BlueView: NSView {
  override func drawRect(dirtyRect: NSRect) {
    NSColor(calibratedRed:0.227, green:0.463, blue:0.733, alpha:1.00).set()
    NSRectFill(dirtyRect);
  }
}
