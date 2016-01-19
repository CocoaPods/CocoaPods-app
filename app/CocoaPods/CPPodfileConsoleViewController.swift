import Cocoa

class CPPodfileConsoleViewController: NSViewController, NSTextViewDelegate {
  @IBOutlet var textView: NSTextView!

  dynamic var editable = false // the textview in the storyboard is bound to this
    
  override func viewDidLoad() {
    super.viewDidLoad()

    let settings = CPFontAndColourGateKeeper()
    textView.font = settings.defaultFont;
  }
}
