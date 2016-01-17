import Cocoa

class CPHomeSidebarButton: NSButton {

  override func awakeFromNib() {
    self.attributedTitle =  NSAttributedString(title, color: NSColor(calibratedWhite: 0.8, alpha: 1), font: .labelFontOfSize(12), alignment: .Center)

    self.attributedAlternateTitle = NSAttributedString(title, color: .blueColor(), font: .labelFontOfSize(12), alignment: .Center)
  }
}
