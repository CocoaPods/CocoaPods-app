import Cocoa

class CPPodfileConsoleTextView: NSTextView {
  
  dynamic var hasText: Bool = false //Currently bound to the hidden property of the console hint button
  
  // We bind to `attributedText`, not `attributedString` in the storyboard, this is
  // to allow us to calculate the previous scroll position before setting the new
  // `attributedString` value which updates the text view
  var attributedText: NSAttributedString? {
    
    didSet {
      guard let attributedText = attributedText else {
        hasText = false
        return
      }
      
      // Determine if we're at the tail of the output log (and should scroll) before we append more to it.
      
      let scrolledToBottom = NSMaxY(self.visibleRect) != NSMaxY(self.bounds)
      
      // Setting via `textStorage` as we cannot call `setAttributedString` directly
      
      self.textStorage?.setAttributedString(attributedText)
      self.hasText = attributedText.length != 0
      
      // Keep the text view at the bottom if it was previously, otherwise restore the previous position.
      
      if (scrolledToBottom) {
        self.scrollToEndOfDocument(self)
      } else {
        self.scrollPoint(self.visibleRect.origin)
      }
    }
  }
}
