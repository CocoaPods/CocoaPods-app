import Cocoa

class TransparentWhiteView: NSView {
  override func draw(_ dirtyRect: NSRect) {
    NSColor(calibratedWhite: 1, alpha: 0.3).set()
    dirtyRect.fill();
  }
}

class TransparentBrownView: NSView {
  override func draw(_ dirtyRect: NSRect) {
    NSColor(red: 56/256, green: 1/256, blue: 0, alpha: 0.6).set()
    dirtyRect.fill();
  }
}

class BrownView: NSView {
  override func draw(_ dirtyRect: NSRect) {
    NSColor(red: 56/256, green: 1/256, blue: 0, alpha: 1).set()
    dirtyRect.fill();
  }
}

class BlueView: NSView {
  override func draw(_ dirtyRect: NSRect) {
    NSColor(calibratedRed:0.227, green:0.463, blue:0.733, alpha:1.00).set()
    dirtyRect.fill();
  }
}
