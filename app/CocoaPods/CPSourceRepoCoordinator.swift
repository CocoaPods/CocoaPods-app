import Cocoa

class CPSourceRepoCoordinator: NSObject, CPCLITaskDelegate {
  var repoSources = [String: String]()
  dynamic var reposNeedUpdating = false

  var checkTask: CPCLITask?

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
    }
  }

  func taskCompleted(task: CPCLITask!) {
    willChangeValueForKey("reposNeedUpdating")
    reposNeedUpdating = !task.finishedSuccessfully()
    didChangeValueForKey("reposNeedUpdating")

    print(reposNeedUpdating)
  }
}
