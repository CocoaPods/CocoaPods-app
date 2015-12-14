import Cocoa

class CPBrownVisualEffectsView: NSVisualEffectView {

  override func awakeFromNib() {

    let brown = BrownView(frame: self.bounds)
    brown.translatesAutoresizingMaskIntoConstraints = false
    addSubview(brown, positioned: .Below, relativeTo: nil)

    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":brown]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":brown]))
  }
}

class BrownView: NSView {
  override func drawRect(dirtyRect: NSRect) {
    NSColor.init(colorLiteralRed: 56/256, green: 1/256, blue: 0, alpha: 0.6).set()
    NSRectFill(dirtyRect);
  }
}

class BlueView: NSView {
    override func drawRect(dirtyRect: NSRect) {
      NSColor(calibratedRed:0.227, green:0.463, blue:0.733, alpha:1.00).set()
      NSRectFill(dirtyRect);
  }
}
