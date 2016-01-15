import Cocoa

/// Useful for when you want to provide some labels in IB, but not in the actual app.

class CPInterfaceBuilderOnlyLabels: NSTextField {

  override func awakeFromNib() {
    removeFromSuperview()
  }

}
