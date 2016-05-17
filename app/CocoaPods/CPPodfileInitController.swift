import Foundation

public enum CPPodfileInitErrors: ErrorType {
  case CommandError(String)
  case NSURLError
  
  var message: String {
    switch self {
    case .CommandError(let s): return s
    case .NSURLError: return "NSURL unexpectedly nil"
    }
  }
}

public class CPPodfileInitController: NSObject, CPCLITaskDelegate {
  private var task: CPCLITask!
  private let completionHandler: (NSURL?, CPPodfileInitErrors?) -> ()
  private let output = NSMutableAttributedString()
  private let projectURL: NSURL
  
  init(xcodeprojURL: NSURL, completionHandler: (podfileURL: NSURL?, error: CPPodfileInitErrors?) -> ()) {
    self.completionHandler = completionHandler
    self.projectURL = xcodeprojURL
    
    super.init()

    self.task = CPCLITask(workingDirectory: xcodeprojURL.URLByDeletingLastPathComponent!.path,
      command: "init",
      arguments: [xcodeprojURL.lastPathComponent!],
      delegate: self,
      qualityOfService: .UserInitiated)
    self.task.run()
  }
  
  public func task(task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    output.appendAttributedString(updatedOutput)
  }
  
  public func taskCompleted(task: CPCLITask!) {
    guard task.finishedSuccessfully() else {
      self.callbackWithError(CPPodfileInitErrors.CommandError(self.output.string))
      return
    }
    
    guard let podfileURL = projectURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("Podfile") where NSFileManager().fileExistsAtPath(podfileURL.path ?? "")
    else {
      self.callbackWithError(CPPodfileInitErrors.NSURLError)
      return
    }
    
    callbackWithSuccess(podfileURL)
  }
  
  private func callbackWithError(error: CPPodfileInitErrors) {
    dispatch_async(dispatch_get_main_queue()) {
      self.completionHandler(nil, error)
    }
  }
  
  private func callbackWithSuccess(url: NSURL) {
    dispatch_async(dispatch_get_main_queue()) {
      self.completionHandler(url, nil)
    }
  }
}