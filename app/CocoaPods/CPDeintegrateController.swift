import Foundation

public enum CPDeintegrateErrors: Error {
  case commandError(String)

  var message: String {
    switch self {
    case .commandError(let s): return s
    }
  }
}

class CPDeintegrateController: NSObject, CPCLITaskDelegate {
  let xcodeprojURL: URL
  fileprivate let completionHandler: (CPDeintegrateErrors?) -> ()
  fileprivate var task: CPCLITask!
  fileprivate let output = NSMutableAttributedString()

  init(xcodeprojURL: URL, completionHandler: @escaping (_ error: CPDeintegrateErrors?) -> ()) {
    self.xcodeprojURL = xcodeprojURL
    self.completionHandler = completionHandler
    super.init()
    self.task = CPCLITask(workingDirectory: xcodeprojURL.deletingLastPathComponent().path,
                          command: "deintegrate",
                          arguments: [],
                          delegate: self,
                          qualityOfService: .userInitiated)
    self.task.run()
  }

  func task(_ task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    output.append(updatedOutput)
  }

  func taskCompleted(_ task: CPCLITask!) {
    guard task.finishedSuccessfully() else {
      self.callbackWithError(CPDeintegrateErrors.commandError(self.output.string))
      return
    }

    callbackWithSuccess()
  }

  fileprivate func callbackWithError(_ error: CPDeintegrateErrors) {
    DispatchQueue.main.async {
      self.completionHandler(error)
    }
  }

  fileprivate func callbackWithSuccess() {
    DispatchQueue.main.async {
      self.completionHandler(nil)
    }
  }
}
