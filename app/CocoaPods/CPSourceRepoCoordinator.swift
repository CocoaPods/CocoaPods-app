import Cocoa

class CPSourceRepoCoordinator: NSObject {
  var repoSources = [String: String]()

  // When these two are true then the binding for enabled on the
  // popover button changes to true
  dynamic var reposNeedUpdating = false
  dynamic var hasAllCocoaPodsRepoSources = false

  var checkTask: CPCLITask?
  var popover: NSPopover?


  func getSourceRepos(userProject: CPUserProject) {
    guard let reflection = NSApp.delegate as? CPAppDelegate else {
      return NSLog("App delegate not CPAppDelegate")
    }
    guard let reflector = reflection.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return NSLog("Could not get a reflection service")
    }

    checkTask = CPCLITask(userProject: userProject, command: "check", delegate: self, qualityOfService: .Utility)
    checkTask?.run()

    reflector.allCocoaPodsSources { sources, error in
      self.repoSources = sources
      self.hasAllCocoaPodsRepoSources = true
    }
  }

  func showRepoSourcesPopover(button: NSButton, userProject:CPUserProject, storyboard: NSStoryboard) {
    guard let viewController = storyboard.instantiateControllerWithIdentifier("RepoSources") as? CPSourceReposViewController else { return }

    let activeProjects = repoSources.filter { userProject.podfileSources.contains($0.1) }.map {
      return CPSourceRepo(name: $0.0, address: $0.1, userProject: userProject)
    }

    let inactiveProjects = repoSources.filter { userProject.podfileSources.contains($0.1) == false }.map {
      return CPSourceRepo(name: $0.0, address: $0.1, userProject: userProject)
    }

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
  let userProject: CPUserProject

  init(name: String, address: String, userProject: CPUserProject) {
    self.address = address
    self.name = name
    self.userProject = userProject
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

    updateRepoTask = CPCLITask(userProject: userProject, command: "repo update \(name)", delegate: self, qualityOfService: .Utility)
    updateRepoTask?.run()
  }

  func taskCompleted(task: CPCLITask!) {
    isUpdatingRepo = false
  }
}