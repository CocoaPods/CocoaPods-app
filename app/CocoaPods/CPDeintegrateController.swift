import Foundation

public enum CPDeintegrateErrors: ErrorType {
  case CommandError(String)

  var message: String {
    switch self {
    case .CommandError(let s): return s
    }
  }
}

class CPDeintegrateController: NSObject, CPCLITaskDelegate {
  let xcodeprojURL: NSURL
  private let completionHandler: (CPDeintegrateErrors?) -> ()
  private var task: CPCLITask!
  private let output = NSMutableAttributedString()

  init(xcodeprojURL: NSURL, completionHandler: (error: CPDeintegrateErrors?) -> ()) {
    self.xcodeprojURL = xcodeprojURL
    self.completionHandler = completionHandler
    super.init()
    self.task = CPCLITask(workingDirectory: xcodeprojURL.URLByDeletingLastPathComponent!.path,
                          command: "deintegrate",
                          arguments: [],
                          delegate: self,
                          qualityOfService: .UserInitiated)
    self.task.run()
  }

  func task(task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    output.appendAttributedString(updatedOutput)
  }

  func taskCompleted(task: CPCLITask!) {
    guard task.finishedSuccessfully() else {
      self.callbackWithError(CPDeintegrateErrors.CommandError(self.output.string))
      return
    }

    callbackWithSuccess()
  }

  private func callbackWithError(error: CPDeintegrateErrors) {
    dispatch_async(dispatch_get_main_queue()) {
      self.completionHandler(error)
    }
  }

  private func callbackWithSuccess() {
    dispatch_async(dispatch_get_main_queue()) {
      self.completionHandler(nil)
    }
  }
}
