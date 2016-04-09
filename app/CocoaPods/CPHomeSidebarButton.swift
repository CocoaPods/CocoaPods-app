import Cocoa

/// The buttons at the top of the sidebar that let
/// you switch between spotlight and recents

class CPHomeSidebarButton: NSButton {

  // Setting `enabled` to false, will color the text `disabledControlTextColor` which we use as the selected state color
  // By adding `userInteractionEnabled` we can disable interaction while still having the color we want when deselected
  // Using this boolean we override the mouse events and first responder as needed
  var userInteractionEnabled: Bool = true
  
  override func awakeFromNib() {
    // This is the title for deselected, e.g. NSOffState
    self.attributedTitle =  NSAttributedString(title, color: NSColor(calibratedWhite: 0.8, alpha: 1), font: .labelFontOfSize(12), alignment: .Center)
    
    // This alternate title is the attributes used when selected, e.g. NSOnState
    // `disabledControlTextColor` is used as this was the previous color for the selected state
    self.attributedAlternateTitle = NSAttributedString(title, color: .disabledControlTextColor(), font: .labelFontOfSize(12), alignment: .Center)
  }
 
  override func mouseDown(theEvent: NSEvent) {
    if userInteractionEnabled {
      super.mouseDown(theEvent)
    }
  }
  
  override func mouseUp(theEvent: NSEvent) {
    if userInteractionEnabled {
      super.mouseUp(theEvent)
    }
  }

  override func becomeFirstResponder() -> Bool {
    return userInteractionEnabled
  }
}
