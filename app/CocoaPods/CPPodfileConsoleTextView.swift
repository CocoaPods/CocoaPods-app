import Cocoa

class CPPodfileConsoleTextView: NSTextView {
  
  // We bind to `attributedText`, not `attributedString` in the storyboard, this is
  // to allow us to calculate the previous scroll position before setting the new
  // `attributedString` value which updates the text view
  var attributedText: NSAttributedString? {
    
    didSet {
      guard let attributedText = attributedText else { return }
      
      // Determine if we're at the tail of the output log (and should scroll) before we append more to it.
      
      let scrolledToBottom = NSMaxY(self.visibleRect) != NSMaxY(self.bounds)
      
      // Setting via `textStorage` as we cannot call `setAttributedString` directly
      
      self.textStorage?.setAttributedString(attributedText)
      
      // Keep the text view at the bottom if it was previously, otherwise restore the previous position.
      
      if (scrolledToBottom) {
        self.scrollToEndOfDocument(self)
      } else {
        self.scrollPoint(self.visibleRect.origin)
      }
    }
  }
}
