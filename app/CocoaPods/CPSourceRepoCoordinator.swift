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
      self.allRepos =  sources.map { CPSourceRepo(name: $0.0, address: $0.1) }
      self.hasAllCocoaPodsRepoSources = true

      if let callback = callback {
        callback(self.allRepos)
      }
    }
  }

  func checkWhetherProjectNeedsChanges(userProject: CPUserProject) {
    checkTask = CPCLITask(userProject: userProject, command: "check", delegate: self, qualityOfService: .Utility)
    checkTask?.run()
  }

  // Could these move to their own class just for the Podfile VC?
  var popover: NSPopover?

  func showRepoSourcesPopover(button: NSButton, userProject:CPUserProject, storyboard: NSStoryboard) {

    let activeProjects = allRepos.filter { userProject.podfileSources.contains($0.address) }
    let inactiveProjects = allRepos.filter { userProject.podfileSources.contains($0.address) == false }

    guard let viewController = storyboard.instantiateControllerWithIdentifier("RepoSources") as? CPSourceReposViewController else { return }


    let popover = NSPopover()
    popover.contentViewController = viewController
    popover.behavior = .Transient

    viewController.setActiveSourceRepos(activeProjects, inactiveRepos: inactiveProjects)
    popover.contentSize = NSSize(width: 400, height: viewController.heightOfData())

    popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MaxY)
    self.popover = popover
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

  var displayName: String {
    return name == "master" ? "CocoaPods Public Specs" : name.capitalizedString
  }

  var displayAddress: String {
    return address
      .stringByReplacingOccurrencesOfString("https://", withString: "")
      .stringByReplacingOccurrencesOfString("www.", withString: "")
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