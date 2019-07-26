import Foundation

public enum CPPodfileInitErrors: Error {
  case commandError(String)
  case nsurlError
  
  var message: String {
    switch self {
    case .commandError(let s): return s
    case .nsurlError: return "NSURL unexpectedly nil"
    }
  }
}

open class CPPodfileInitController: NSObject, CPCLITaskDelegate {
  fileprivate var task: CPCLITask!
  fileprivate let completionHandler: (URL?, CPPodfileInitErrors?) -> ()
  fileprivate let output = NSMutableAttributedString()
  fileprivate let projectURL: URL
  
  init(xcodeprojURL: URL, completionHandler: @escaping (_ podfileURL: URL?, _ error: CPPodfileInitErrors?) -> ()) {
    self.completionHandler = completionHandler
    self.projectURL = xcodeprojURL
    
    super.init()

    self.task = CPCLITask(workingDirectory: xcodeprojURL.deletingLastPathComponent().path,
      command: "init",
      arguments: [xcodeprojURL.lastPathComponent],
      delegate: self,
      qualityOfService: .userInitiated)
    self.task.run()
  }
  
  open func task(_ task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    output.append(updatedOutput)
  }
  
  open func taskCompleted(_ task: CPCLITask!) {
    guard task.finishedSuccessfully() else {
      self.callbackWithError(CPPodfileInitErrors.commandError(self.output.string))
      return
    }
    
    let podfileURL = projectURL.deletingLastPathComponent().appendingPathComponent("Podfile")
    guard FileManager().fileExists(atPath: podfileURL.path)
    else {
      self.callbackWithError(CPPodfileInitErrors.nsurlError)
      return
    }
    
    callbackWithSuccess(podfileURL)
  }
  
  fileprivate func callbackWithError(_ error: CPPodfileInitErrors) {
    DispatchQueue.main.async {
      self.completionHandler(nil, error)
    }
  }
  
  fileprivate func callbackWithSuccess(_ url: URL) {
    DispatchQueue.main.async {
      self.completionHandler(url, nil)
    }
  }
}
