import Cocoa

class CPPodfileConsoleViewController: NSViewController, NSTextViewDelegate {
  @IBOutlet var textView: NSTextView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let settings = CPFontAndColourGateKeeper()
    textView.font = settings.defaultFont;
  }

  func textView(textView: NSTextView, willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue], toCharacterRanges newSelectedCharRanges: [NSValue]) -> [NSValue] {

    // Determine if we're at the tail of the output log (and should scroll) before we append more to it.

    guard let scrollView = textView.enclosingScrollView else { return newSelectedCharRanges }

    let visibleRect = scrollView.documentVisibleRect
    let maxContentOffset = textView.bounds.size.height - visibleRect.size.height
    let scrolledToBottom = visibleRect.origin.y == maxContentOffset

    // Keep the text view at the bottom if it was previously, otherwise restore the previous position.

    if (scrolledToBottom) {
      textView.scrollToEndOfDocument(self)
    } else {
      textView.scrollPoint(visibleRect.origin)
    }

    return newSelectedCharRanges
  }

}
