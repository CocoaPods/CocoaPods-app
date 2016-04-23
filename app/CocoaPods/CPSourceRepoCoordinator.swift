import Cocoa

class CPSourceRepoCoordinator: NSObject {

  var allRepos = [CPSourceRepo]()

  // When these two are true then the binding for enabled on the
  // popover button changes to true
  dynamic var reposNeedUpdating = false
  dynamic var hasAllCocoaPodsRepoSources = false

  var checkTask: CPCLITask?

  // Gets source repos, with an optional callback for the repos.
  func getSourceRepos(callback: (([CPSourceRepo])->())? = nil) {
    guard let reflection = NSApp.delegate as? CPAppDelegate else {
      return NSLog("App delegate not CPAppDelegate")
    }
    guard let reflector = reflection.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return NSLog("Could not get a reflection service")
    }

    reflector.allCocoaPodsSources { sources, error in
      let unordered_sources =  sources.map { CPSourceRepo(name: $0.0, address: $0.1) }
      self.allRepos = unordered_sources.sort(self.cocoaPodsSpecSort)

      self.hasAllCocoaPodsRepoSources = true

      if let callback = callback {
        callback(self.allRepos)
      }
    }
  }

  // Moves the CP specs repo to the top, and then does alphabetical after that
  func cocoaPodsSpecSort(lhs: CPSourceRepo, rhs: CPSourceRepo) -> Bool {
    if lhs.isCocoaPodsSpecs { return true }
    if rhs.isCocoaPodsSpecs { return false }
    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == NSComparisonResult.OrderedAscending
  }

  func checkWhetherProjectNeedsChanges(userProject: CPUserProject) {
    checkTask = CPCLITask(userProject: userProject, command: "check", delegate: self, qualityOfService: .Utility)
    checkTask?.run()
  }
}

extension CPSourceRepoCoordinator: CPCLITaskDelegate {
  func taskCompleted(task: CPCLITask!) {
    reposNeedUpdating = !task.finishedSuccessfully()
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
    return isCocoaPodsSpecs ? "CocoaPods Public Specs" : name.capitalizedString
  }

  var displayAddress: String {
    return address
      .stringByReplacingOccurrencesOfString("https://", withString: "")
      .stringByReplacingOccurrencesOfString("www.", withString: "")
      .stringByReplacingOccurrencesOfString("git.", withString: "")
      .stringByReplacingOccurrencesOfString("@git", withString: "")
  }

  dynamic var isUpdatingRepo: Bool = false
  var updateRepoTask: CPCLITask?

  @IBAction func updateRepo(button: NSButton?) {
    self.isUpdatingRepo = true

    updateRepoTask = CPCLITask(workingDirectory: NSTemporaryDirectory(), command: "repo update \(name)", delegate: self, qualityOfService: .UserInteractive)
    updateRepoTask?.run()
  }

  func taskCompleted(task: CPCLITask!) {
    isUpdatingRepo = false
  }
}