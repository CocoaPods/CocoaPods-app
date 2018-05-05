import Cocoa

class CPSourceRepoCoordinator: NSObject {

  var allRepos = [CPSourceRepo]()

  // When these two are true then the binding for enabled on the
  // popover button changes to true
  dynamic var reposNeedUpdating = false
  dynamic var hasAllCocoaPodsRepoSources = false

  var checkTask: CPCLITask?
  dynamic var imageForShowReposPopover: NSImage?

  override func awakeFromNib() {
    super.awakeFromNib()
    imageForShowReposPopover = NSImage(named: "repo_update_not_ready")
  }

  // Gets source repos, with an optional callback for the repos.
  func getSourceRepos(_ callback: (([CPSourceRepo])->())? = nil) {
    guard let reflection = NSApp.delegate as? CPAppDelegate else {
      return NSLog("App delegate not CPAppDelegate")
    }
    guard let reflector = reflection.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return NSLog("Could not get a reflection service")
    }

    reflector.allCocoaPodsSources { sources, error in
      let unordered_sources =  sources.map { CPSourceRepo(name: $0.0, address: $0.1) }
      self.allRepos = unordered_sources.sorted(by: self.cocoaPodsSpecSort)

      self.hasAllCocoaPodsRepoSources = true

      if let callback = callback {
        callback(self.allRepos)
      }
    }
  }

  // Moves the CP specs repo to the top, and then does alphabetical after that
  func cocoaPodsSpecSort(_ lhs: CPSourceRepo, rhs: CPSourceRepo) -> Bool {
    if lhs.isCocoaPodsSpecs { return true }
    if rhs.isCocoaPodsSpecs { return false }
    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
  }

  func checkWhetherProjectNeedsChanges(_ userProject: CPUserProject) {
    checkTask = CPCLITask(userProject: userProject, command: "check", arguments: [], delegate: self, qualityOfService: .utility)
    checkTask?.run()
  }
}

extension CPSourceRepoCoordinator: CPCLITaskDelegate {
  func taskCompleted(_ task: CPCLITask!) {
    reposNeedUpdating = !task.finishedSuccessfully()
    let imageName = reposNeedUpdating ? "repo_update_not_ready" : "repo_update_needed"
    imageForShowReposPopover = NSImage(named: imageName)
  }
}

class CPSourceRepo: NSObject, CPCLITaskDelegate {
  let name: String
  let address: String

  init(name: String, address: String) {
    self.address = address
    self.name = name
  }

  var isCocoaPodsSpecs: Bool {
    return name == "master"
  }

  var displayName: String {
    return isCocoaPodsSpecs ? "CocoaPods Public Specs" : name.capitalized
  }

  var displayAddress: String {
    return address
      .replacingOccurrences(of: "https://", with: "")
      .replacingOccurrences(of: "www.", with: "")
      .replacingOccurrences(of: "git.", with: "")
      .replacingOccurrences(of: "@git", with: "")
  }

  dynamic var isUpdatingRepo: Bool = false
  var updateRepoTask: CPCLITask?

  @IBAction func updateRepo(_ button: NSButton?) {
    self.isUpdatingRepo = true

    updateRepoTask = CPCLITask(workingDirectory: NSTemporaryDirectory(), command: "repo update", arguments: [name], delegate: self, qualityOfService: .userInteractive)
    updateRepoTask?.run()
  }

  var recentlyUpdated = false
  func taskCompleted(_ task: CPCLITask!) {
    isUpdatingRepo = false
    recentlyUpdated = true
    
    if task.finishedSuccessfully() {
      notifyWithTitle(~"REPO_UPDATE_NOTIFICATION_TITLE")
    } else {
      notifyWithTitle(~"REPO_UPDATE_FAILED_NOTIFICATION_TITLE")
    }
  }

  fileprivate func notifyWithTitle(_ title: String) {
    let notification = NSUserNotification()
    notification.title = title
    notification.subtitle = displayName
    NotificationCenter.default.post(name: Notification.Name(rawValue: "CPRepoUpdatedCompleted"), object: nil)
    NSUserNotificationCenter.default.deliver(notification)
  }
}
