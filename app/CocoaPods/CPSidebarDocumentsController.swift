import Cocoa

class CPSidebarDocumentsController: NSObject {

  // This changes between Recent and Spotlight docs
  dynamic var currentSidebarItems = [CPHomeWindowDocumentEntry]()

  // for bindings to show a progress during spotlight metadata
  // searching
  dynamic var loading = false

  @IBOutlet weak var recentButton: NSButton!
  @IBOutlet weak var spotlightButton: NSButton!

  var buttons :[NSButton] { return [recentButton, spotlightButton] }

  @IBOutlet weak var spotlightSource: CPSpotlightDocumentSource!
  @IBOutlet weak var recentSource: CPRecentDocumentSource!

  override func awakeFromNib() {
    if recentSource.recentDocuments.count > 0 {
      recentButtonTapped(recentButton)
    } else {
      spotlightButtonTapped(spotlightButton)
    }
  }

  @IBAction func recentButtonTapped(sender: NSButton) {
    currentSidebarItems = recentSource.recentDocuments
    selectButton(sender)
  }

  @IBAction func spotlightButtonTapped(sender: NSButton) {
    let source = spotlightSource
    currentSidebarItems = source.documents
    selectButton(sender)

    // Could either be no podfiles
    // on the users computer - or still searching
    // in which case we use the promise to know
    // for sure

    if source.documents.isEmpty {
      loading = true
      spotlightSource.completedPromise.addBlock {
        self.loading = false

        let stillSelectedSpotlight = !sender.enabled
        if !stillSelectedSpotlight { return }

        if source.documents.isEmpty {
          self.showPopoverForOpenPodfile()
        } else {

          // Re-run the press now there's content
          self.spotlightButtonTapped(sender)
        }
      }
    }
  }

  @IBOutlet weak var openPodfileView: NSView!
  @IBOutlet weak var documentScrollView: NSScrollView!
  func showPopoverForOpenPodfile() {

    // Setup the title for the button
    let title = NSLocalizedString("MAIN_WINDOW_OPEN_DOCUMENT_BUTTON_TITLE", comment:"")
    let buttonTitle = NSAttributedString.init(title, color: .CPDarkColor(), font: .labelFontOfSize(13), alignment: .Center)
    let altButtonTitle = NSAttributedString.init(title, color: .CPDarkColor(), font: .labelFontOfSize(13), alignment: .Center)

    for case let button as NSButton in openPodfileView.subviews {
      button.attributedTitle = buttonTitle
      button.attributedAlternateTitle = altButtonTitle
    }

    // Replace the tableview with our "Open Podfile" button
    documentScrollView.hidden = true
    openPodfileView.frame = documentScrollView.frame
    documentScrollView.superview?.addSubview(openPodfileView)

    // Make sure that you can't tap change the doc types that will do nothing
    buttons.forEach { self.enableButton($0, select: false) }
  }

  func selectButton(button:NSButton) {
    enableButton(button, select:true)

    let otherButtons = buttons.filter { $0 != button }
    otherButtons.forEach { self.enableButton($0, select:false) }
  }

  func enableButton(button:NSButton, select:Bool) {
//    button.bordered = select
    button.enabled = !select
  }
}
