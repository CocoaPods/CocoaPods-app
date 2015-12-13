import Cocoa

private let dimmedOpacity: Float = 0.3

class CPSideButton: NSButton {

  override func awakeFromNib() {
    super.awakeFromNib()

    // We do our own dimming.
    (self.cell as? NSButtonCell)?.imageDimsWhenDisabled = false
    self.wantsLayer = true
    self.layer?.opacity = dimmedOpacity
  }

  override var enabled: Bool {
    didSet {
      // We are inferring that if we are disabled, then we are the currently selected button.
      // The current selected button is the only one that gets full opacity.
      let alpha = enabled ? dimmedOpacity : 1.0
      self.layer?.opacity = alpha
    }
  }

}
