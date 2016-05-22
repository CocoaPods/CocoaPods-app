import Cocoa

enum InstallActionType {
  case Install(options: InstallOptions)
  case Update(options: InstallOptions)
}

struct InstallOptions {
  let verbose: Bool

  var commandOptions : [String] {
    var opts = [String]()
    if verbose { opts.append("--verbose") }
    return opts
  }
}

class CPInstallAction: NSObject, CPCLITaskDelegate {
  let userProject: CPUserProject
  let notify: Bool
  dynamic var taskAttributedString: NSAttributedString?
  dynamic var task: CPCLITask?

  init(userProject: CPUserProject, notify: Bool) {
    self.userProject = userProject
    self.notify = notify
  }

  func performAction(type: InstallActionType) {
    switch type {
    case .Install(let options):
      executeTaskWithCommand("install", args: options.commandOptions)
    case .Update(let options):
      executeTaskWithCommand("update", args: options.commandOptions)
    }
  }

  private func executeTaskWithCommand(command: String, args: [String]) {
    task = CPCLITask(userProject: userProject, command: command, arguments: args, delegate: self, qualityOfService: .UserInitiated)
    guard let task = task else { return }

    task.colouriseOutput = true
    task.run()
  }

  func task(task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    self.taskAttributedString = updatedOutput
  }

  func taskCompleted(task: CPCLITask!) {
    if (notify) {
      if task.finishedSuccessfully() {
        notifyWithTitle(~"WORKSPACE_GENERATED_NOTIFICATION_TITLE")
      } else {
        notifyWithTitle(~"WORKSPACE_FAILED_GENERATION_NOTIFICATION_TITLE")
      }
    }
  }

  private func notifyWithTitle(title: String) {
    let notification = NSUserNotification()
    notification.title = title
    if let path = userProject.fileURL?.relativePath {
      notification.subtitle = (path as NSString).stringByAbbreviatingWithTildeInPath
    }
    NSNotificationCenter.defaultCenter().postNotificationName("CPInstallCompleted", object: nil)
    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
  }
}
