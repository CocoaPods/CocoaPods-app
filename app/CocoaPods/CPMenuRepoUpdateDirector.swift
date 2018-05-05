import Cocoa

class CPMenuRepoUpdateDirector: NSObject {
  let repoCoordinator = CPSourceRepoCoordinator()

  // The thing that you click on, in the main menu
  @IBOutlet weak var sourceReposMenuItem: NSMenuItem!

  // The representation of the things that would show when clicked
  @IBOutlet weak var sourceReposMenu: NSMenu!

  override func awakeFromNib() {
    super.awakeFromNib()

    // Don't let it be clickable when there's nothing to show
    sourceReposMenuItem.isEnabled = false
    sourceReposMenu.removeAllItems()

    // Once everything's finished then we start looking for repo sources,
    // and re-run it after every pod install/update, which may have
    // added new sources

    for key in [NSNotification.Name.NSApplicationDidFinishLaunching, NSNotification.Name("CPInstallCompleted")] {
      let center = NotificationCenter.default
      center.addObserver(self, selector: #selector(lookForSources), name:key, object: nil)
    }
  }

  func lookForSources() {
    repoCoordinator.getSourceRepos { sources in
      /// This can be on any thread, we want to do GUI work though
      DispatchQueue.main.async {
       self.createMenuForSources(sources)
      }
    }
  }

  func createMenuForSources(_ sources: [CPSourceRepo]) {
    sourceReposMenu.removeAllItems()
    sourceReposMenuItem.isEnabled = !sources.isEmpty

    let menuItems = sources.map(menuItemForRepo)
    for menu in menuItems { sourceReposMenu.addItem(menu) }
  }

  func menuItemForRepo(_ source: CPSourceRepo) -> NSMenuItem {
    let menuItem = NSMenuItem()
    menuItem.view = CPSourceMenuView(source:source)
    menuItem.representedObject = source
    return menuItem
  }
}

class CPSourceMenuView: NSView {

  // I know, it's a weird one, but with this textfield
  // and that custom drawRect, we get the right highlight
  // for an NSMenuItem in all it's many possible states. :)
  var backgroundHighlightView: NSTextField!

  // Views used in the menu items
  var titleLabel: NSTextField!
  var subtitleLabel: NSTextField!
  var updateButtonBG: NSImageView!
  var progress: NSProgressIndicator!
  var completedLabel: NSTextField!

  var containsMouse = false {
    didSet {
      setNeedsDisplay(bounds)
    }
  }

  // Orta uses a dark menu bar, this was my favourite
  // feature in Yosemite, I used to hack this in before.

  var menuIsDarkMode: Bool {
    let appearance =  NSAppearance.current()
    return appearance.name.hasPrefix("NSAppearanceNameVibrantDark")
  }

  var source: CPSourceRepo? {
    return enclosingMenuItem?.representedObject as? CPSourceRepo
  }

  convenience init(source: CPSourceRepo) {
    let frame = CGRect(x: 0, y: 0, width: 400, height: 60)
    self.init(frame: frame)

    backgroundHighlightView = label(bounds)
    addSubview(backgroundHighlightView)

    let titleRect = CGRect(x: 20, y: 30, width: 240, height: 20)
    titleLabel = label(titleRect)
    titleLabel.stringValue = source.displayName
    titleLabel.font = NSFont.menuBarFont(ofSize: 15)
    addSubview(titleLabel)

    let subtitleRect = CGRect(x: 20, y: 10, width: 240, height: 20)
    subtitleLabel = label(subtitleRect)
    subtitleLabel.stringValue = source.displayAddress
    subtitleLabel.font = NSFont.menuBarFont(ofSize: 14)
    addSubview(subtitleLabel)

    let buttonRect = CGRect(x: 400-20-60, y: 20, width: 60, height: 20)
    updateButtonBG = NSImageView(frame: buttonRect)
    updateButtonBG.imageScaling = .scaleAxesIndependently
    updateButtonBG.image = NSImage(named: "TransparentButtonBG")
    addSubview(updateButtonBG)

    completedLabel = label(buttonRect)
    completedLabel.alignment = .center
    addSubview(completedLabel)

    let progressRect = CGRect(x: 400-20-40, y: 20, width: 20, height: 20)
    progress = NSProgressIndicator(frame: progressRect)
    progress.style = .spinningStyle
    progress.startAnimation(self)
    addSubview(progress)
  }

  func label(_ frame: CGRect) -> NSTextField {
    let label = CPNoFancyTransparencyTextField(frame: frame)
    label.isBezeled = false
    label.drawsBackground = false
    label.isEditable = false
    label.isSelectable = false
    label.usesSingleLineMode = true
    return label
  }

  // The drawing is handled inside a drawrect, as we need
  // to handle the background ourselves.

  override func draw(_ dirtyRect: NSRect) {
    guard let source = source else { return }

    updateButtonBG.isHidden = !containsMouse || source.isUpdatingRepo
    completedLabel.isHidden = !containsMouse || source.isUpdatingRepo
    progress.isHidden = !source.isUpdatingRepo

    if containsMouse {
      let textColor = NSColor.selectedMenuItemTextColor;
      for label in [titleLabel, subtitleLabel, completedLabel] { label?.textColor = textColor }

      completedLabel.stringValue = source.recentlyUpdated ? "👍🏾" : "Update"
      drawSelectionBackground(dirtyRect)

    } else {
      let textColor = menuIsDarkMode ? NSColor.white : NSColor.textColor
      titleLabel.textColor = textColor
      subtitleLabel.textColor = textColor

      super.draw(dirtyRect)
    }
  }

  func drawSelectionBackground(_ dirtyRect: CGRect) {
    // Taken from:
    // https://gist.github.com/joelcox/28de2f0cb21ea47bd789

    NSColor.selectedMenuItemColor.set()
    NSRectFillUsingOperation(dirtyRect, .sourceOver);

    if (dirtyRect.size.height > 1) {
      let heightMinus1 = dirtyRect.size.height - 1
      let currentControlTint = NSColor.currentControlTint
      let startingOpacity: CGFloat = currentControlTint == .blueControlTint ? 0.16 : 0.09

      let gradient = NSGradient(starting: NSColor(white: CGFloat(1.0), alpha:startingOpacity), ending:NSColor(white: CGFloat(1.0), alpha: 0.0))!
      let startPoint = NSMakePoint(dirtyRect.origin.x, dirtyRect.origin.y + heightMinus1)
      let endPoint = NSMakePoint(dirtyRect.origin.x, dirtyRect.origin.y + 1)
      gradient.draw(from: startPoint, to: endPoint, options:NSGradientDrawingOptions.drawsBeforeStartingLocation)

      if currentControlTint == .blueControlTint {
        NSColor(white: CGFloat(1.0), alpha: CGFloat(0.1)).set()

        let smallerRect = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y + heightMinus1, dirtyRect.size.width, CGFloat(1.0))
        NSRectFillUsingOperation(smallerRect, .sourceOver)
      }
    }
  }

  // Ensure we have one tracking reference to get in/out notifications
  override func updateTrackingAreas() {
    if trackingAreas.isEmpty {
      addTrackingArea(
        NSTrackingArea(rect: bounds, options: [.activeWhenFirstResponder, .mouseEnteredAndExited, .enabledDuringMouseDrag], owner: self, userInfo: nil)
      )
    }
  }

  override func mouseEntered(with theEvent: NSEvent) {
    super.mouseEntered(with: theEvent)
    containsMouse = true
  }

  override func mouseExited(with theEvent: NSEvent) {
    super.mouseExited(with: theEvent)
    containsMouse = false
  }

  override func mouseUp(with theEvent: NSEvent) {
    guard let sourceRepo = source else { return }
    sourceRepo.updateRepo(nil)
    setNeedsDisplay(bounds)
  }
}

class CPNoFancyTransparencyTextField : NSTextField {
  override var allowsVibrancy: Bool {
    return false
  }
}
