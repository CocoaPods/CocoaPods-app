import Cocoa

private let dimmedOpacity: Float = 0.3

class CPSideButton: NSButton {

  override func awakeFromNib() {
    super.awakeFromNib()

    // We do our own dimming.
    (cell as? NSButtonCell)?.imageDimsWhenDisabled = false
    wantsLayer = true
    layer?.opacity = enabled ? dimmedOpacity : 1.0
  }

  override var enabled: Bool {
    didSet {
      // We are inferring that if we are disabled, then we are the currently selected button.
      // The current selected button is the only one that gets full opacity.
      let alpha = enabled ? dimmedOpacity : 1.0
      layer?.opacity = alpha
    }
  }

}
