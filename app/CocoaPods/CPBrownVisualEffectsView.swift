import Cocoa

class CPBrownVisualEffectsView: NSVisualEffectView {

  override func awakeFromNib() {

    let brown = TransparentBrownView(frame: self.bounds)
    brown.translatesAutoresizingMaskIntoConstraints = false
    addSubview(brown, positioned: .below, relativeTo: nil)

    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics:nil, views:["subview":brown]))
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics:nil, views:["subview":brown]))
  }
}
