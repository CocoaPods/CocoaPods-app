import Cocoa

class CPBrownVisualEffectsView: NSVisualEffectView {

  override func awakeFromNib() {

    let brown = TransparentBrownView(frame: self.bounds)
    brown.translatesAutoresizingMaskIntoConstraints = false
    addSubview(brown, positioned: .Below, relativeTo: nil)

    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":brown]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics:nil, views:["subview":brown]))
  }
}
