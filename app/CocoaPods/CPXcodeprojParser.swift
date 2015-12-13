import Cocoa

class CPXcodeprojParser: NSObject {
  let userProject: CPUserProject

  init(userProject: CPUserProject) {
    self.userProject = userProject
  }

  func getXcodeIntegrationInformation(completion: ([String:AnyObject]) -> () ) {
    guard let reflector = NSApp.delegate as? CPAppDelegate else {
      return print("App Delegate not hooked up")
    }
    guard let proxy = reflector.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return print("Proxy doesn't conform to CPReflectionServiceProtocol")
    }
    
    proxy.
  }

}
