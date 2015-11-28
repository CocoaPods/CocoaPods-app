import Cocoa

enum InstallActionType {
  case Install(verbose: Bool)
  case Update(verbose: Bool)
}

class CPInstallAction: NSObject, CPCLITaskDelegate {
  let userProject: CPUserProject
  dynamic var taskAttributedString: NSAttributedString?
  dynamic var task: CPCLITask?

  init(userProject: CPUserProject) {
    self.userProject = userProject
  }

  func performAction(type: InstallActionType) {
    switch type {
    case .Install(let verbose):
      executeTaskWithCommand(verbose ? "install --verbose" : "install")
    case .Update(let verbose):
      executeTaskWithCommand(verbose ? "update --verbose" : "update")
    }
  }

  private func executeTaskWithCommand(command: String) {
    task = CPCLITask(userProject: userProject, command: command, delegate: self, qualityOfService: .UserInitiated)
    task?.run()
  }

  func task(task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    self.taskAttributedString = updatedOutput
  }
}
