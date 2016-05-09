import Cocoa

/// UIVIewController to represent the Podfile editor
/// It's scope is keeping track of the user project,
/// handling / exposing tabs and providing a central
/// access place for mutable state within the Podfile
/// section of CocoaPods.app

class CPPodfileViewController: NSViewController, NSTabViewDelegate {

  var userProject: CPUserProject!
  dynamic var installAction: CPInstallAction!

  @IBOutlet weak var actionTitleLabel: NSTextField!
  @IBOutlet weak var documentIconContainer: NSView!

  var pluginCoordinator: CPPodfilePluginCoordinator!
  @IBOutlet var sourcesCoordinator: CPSourceRepoCoordinator!

  @IBOutlet var tabViewDelegate: CPTabViewDelegate!

  override func viewWillAppear() {

    // The userProject is DI'd in after viewDidLoad
    installAction = CPInstallAction(userProject: userProject, notify: true)

    // The view needs to be added to a window before we can use
    // the window to pull out to the document icon from the window

    guard
      let window = view.window as? CPModifiedDecorationsWindow,
      let documentIcon = window.documentIconButton else {
        return print("Window type is not CPModifiedDecorationsWindow")
    }

    // Grab the document icon and move it into the space on our 
    // custom title bar
    documentIcon.frame = documentIcon.bounds
    documentIconContainer.addSubview(documentIcon)

    // Default the bottom label to hidden
    hideWarningLabel(false)

    // Check for whether we need to install plugins
    pluginCoordinator = CPPodfilePluginCoordinator(controller: self)
    pluginCoordinator.comparePluginsWithinUserProject(userProject)

    // Keep track of active source repos
    sourcesCoordinator.getSourceRepos()
    sourcesCoordinator.checkWhetherProjectNeedsChanges(userProject)

    // Makes the tabs highlight correctly
    tabController.hiddenTabDelegate = tabViewDelegate

    // When integrating into one xcodeproj
    // we should show "Podfile for ProjectName" instead
    userProject.registerForFullMetadataCallback {
      guard let targets = self.userProject.xcodeIntegrationDictionary["projects"] as? [String:AnyObject] else { return }
      self.updatePodfileNameIfPossible(targets)
    }
  }

  /// As CP will deintegrate, and re-integrate that app, we should show a warning
  /// that is is going to happen
  /// buildVersion will be cast to a string
  func shouldShowInstallWarningForMajorChange(buildVersion: AnyObject?) -> Bool {
    guard
      let version = buildVersion as? String,
      let majorLastInstallVersion = version.componentsSeparatedByString(".").first,
      let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String,
      let majorAppVersion = appVersion.componentsSeparatedByString(".").first

    else { return false }

    return Int(majorAppVersion) > Int(majorLastInstallVersion)
  }

  func updatePodfileNameIfPossible(targets: [String: AnyObject]) {
    if targets.keys.count == 1 {
      let project = targets.keys.first!
      let url = NSURL(fileURLWithPath: project)
      let name = url.lastPathComponent!.stringByReplacingOccurrencesOfString(".xcproj", withString: "")
      dispatch_async(dispatch_get_main_queue()) {
        self.actionTitleLabel.stringValue = "Podfile for \(name)"
      }
    }
  }

  var tabController: CPHiddenTabViewController {
    return childViewControllers.filter { $0.isKindOfClass(CPHiddenTabViewController) }.first! as! CPHiddenTabViewController
  }

  @IBAction func install(obj: AnyObject) {
    let options = InstallOptions(verbose: false)
    performInstallAction(.Install(options: options))
  }

  @IBAction func installVerbose(obj: AnyObject) {
    let options = InstallOptions(verbose: true)
    performInstallAction(.Install(options: options))
  }

  @IBAction func installUpdate(obj: AnyObject) {
    let options = InstallOptions(verbose: false)
    performInstallAction(.Update(options: options))
  }

  @IBAction func installUpdateVerbose(obj: AnyObject) {
    let options = InstallOptions(verbose: true)
    performInstallAction(.Update(options: options))
  }

  func performInstallAction(action: InstallActionType) {
    userProject.saveDocument(self)

    let lastInstalledVersion = userProject.xcodeIntegrationDictionary["cocoapods_build_version"]
    if shouldShowInstallWarningForMajorChange(lastInstalledVersion) {
      if !promptForInstallMigration(lastInstalledVersion) { return }
    }

    installAction.performAction(action)
    showConsoleTab(self)
  }

  func promptForInstallMigration(buildVersion: AnyObject?) -> Bool {
    guard
      let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String,
      let version = buildVersion as? String else { return true }

    let alert = NSAlert()
    alert.messageText = ~"REINTEGRATION_ALERT_FORMAT_TITLE"
    alert.informativeText = String(format: ~"REINTEGRATION_ALERT_FORMAT_MESSAGE", version, appVersion)
    alert.addButtonWithTitle(~"REINTEGRATION_ALERT_CONFIRM")
    alert.addButtonWithTitle(~"REINTEGRATION_ALERT_CANCEL")
    return alert.runModal() == NSAlertFirstButtonReturn
  }

  @IBOutlet var installMenu: NSMenu!
  @IBAction func showInstallOptions(button: NSButton) {
    guard let event = NSApp.currentEvent else { return }
    NSMenu.popUpContextMenu(installMenu, withEvent: event, forView: button)
  }

  @IBAction func showEditorTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 0
  }

  @IBAction func showConsoleTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 2
  }

  @IBAction func showInformationTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 1
  }

  @IBOutlet weak var warningDoneButton: NSButton!
  @IBOutlet weak var warningLabel: NSTextField!
  @IBOutlet weak var warningView: BlueView!
  @IBOutlet weak var warningLabelHeight: NSLayoutConstraint!

  func showWarningLabelWithSender(message: String, actionTitle: String, target: AnyObject?, action: Selector, animated: Bool) {
    let constraint = warningLabelHeight
    warningLabelHeight.active = false

    warningLabel.stringValue = message
    warningDoneButton.title = actionTitle
    warningDoneButton.target = target
    warningDoneButton.action = action
    warningDoneButton.enabled = true
    view.layoutSubtreeIfNeeded()

    let height = animated ? constraint.animator() : constraint
    height.constant = warningView.fittingSize.height
    warningLabelHeight = constraint
    constraint.active = true
  }

  func hideWarningLabel(animated:Bool = true) {
    view.layoutSubtreeIfNeeded()
    let constraint = animated ? warningLabelHeight.animator() : warningLabelHeight
    constraint.constant = 0
    constraint.active = true
    warningDoneButton.enabled = false
  }

  var popover: NSPopover?

  @IBAction func showSourceRepoUpdatePopover(button: NSButton) {
    // Prevent multiple popovers to be shown when clicking the show source repo update button rapidly
    if let popover = self.popover where popover.shown {
      return
    }

    let podfileSources = userProject.podfileSources
    let allRepos = sourcesCoordinator.allRepos

    let activeProjects: [CPSourceRepo]
    let inactiveProjects: [CPSourceRepo]

    // Handle the implicit CP source repo when none are defined

    if podfileSources.isEmpty {
      activeProjects = allRepos.filter { $0.isCocoaPodsSpecs }
      inactiveProjects = allRepos.filter { !$0.isCocoaPodsSpecs }
    } else {
      activeProjects = allRepos.filter { podfileSources.contains($0.address) }
      inactiveProjects = allRepos.filter { !podfileSources.contains($0.address) }
    }

    guard let viewController = storyboard?.instantiateControllerWithIdentifier("RepoSources") as? CPSourceReposViewController else { return }

    let popover = NSPopover()
    popover.contentViewController = viewController
    popover.behavior = .Transient

    viewController.setActiveSourceRepos(activeProjects, inactiveRepos: inactiveProjects)
    popover.contentSize = NSSize(width: 400, height: viewController.heightOfData())

    popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MaxY)
    self.popover = popover
  }

}

extension NSViewController {

  /// Recurse the parentViewControllers till we find a CPPodfileViewController
  /// this lets child view controllers access this class for shared state.

  var podfileViewController: CPPodfileViewController? {

    guard let parent = self.parentViewController else { return nil }
    if let appVC = parent as? CPPodfileViewController {
      return appVC
    } else {
      return parent.podfileViewController
    }
  }
}
