import Cocoa

class CPSourceRepoCoordinator: NSObject {
  var repoSources = [String: String]()

  func getSourceRepos() {
    guard let reflection = NSApp.delegate as? CPAppDelegate else {
      return NSLog("App delegate not CPAppDelegate")
    }
    guard let reflector = reflection.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return NSLog("Could not get a reflection service")
    }

    reflector.allCocoaPodsSources { sources, error in
      repoSources = sources
    }
  }

}
