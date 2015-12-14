import Cocoa

class CPBorderedButton: NSButton {

  /// Sets centered white text for the font
  override func awakeFromNib() {
    (self.cell as? NSButtonCell)?.imageDimsWhenDisabled = false



    let style = NSMutableParagraphStyle()
    style.alignment = .Center

    self.attributedTitle = NSAttributedString(string: title, attributes: [
      NSForegroundColorAttributeName: NSColor(calibratedWhite: 1, alpha: 1),
      NSFontAttributeName: font!,
      NSParagraphStyleAttributeName: style
    ])
  }
}
