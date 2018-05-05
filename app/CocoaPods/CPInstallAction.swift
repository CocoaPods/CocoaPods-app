import Cocoa

enum InstallActionType {
  case install(options: InstallOptions)
  case update(options: InstallOptions)
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
  @objc dynamic var taskAttributedString: NSAttributedString?
  @objc dynamic var task: CPCLITask?

  init(userProject: CPUserProject, notify: Bool) {
    self.userProject = userProject
    self.notify = notify
  }

  func performAction(_ type: InstallActionType) {
    switch type {
    case .install(let options):
      executeTaskWithCommand("install", args: options.commandOptions)
    case .update(let options):
      executeTaskWithCommand("update", args: options.commandOptions)
    }
  }

  fileprivate func executeTaskWithCommand(_ command: String, args: [String]) {
    task = CPCLITask(userProject: userProject, command: command, arguments: args, delegate: self, qualityOfService: .userInitiated)
    guard let task = task else { return }

    task.colouriseOutput = true
    task.run()
  }

  func task(_ task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    self.taskAttributedString = updatedOutput
  }

  func taskCompleted(_ task: CPCLITask!) {
    if (notify) {
      if task.finishedSuccessfully() {
        notifyWithTitle(~"WORKSPACE_GENERATED_NOTIFICATION_TITLE")
      } else {
        notifyWithTitle(~"WORKSPACE_FAILED_GENERATION_NOTIFICATION_TITLE")
      }
    }
  }

  fileprivate func notifyWithTitle(_ title: String) {
    let notification = NSUserNotification()
    notification.title = title
    if let path = userProject.fileURL?.relativePath {
      notification.subtitle = (path as NSString).abbreviatingWithTildeInPath
    }
    NotificationCenter.default.post(name: Notification.Name(rawValue: "CPInstallCompleted"), object: nil)
    NSUserNotificationCenter.default.deliver(notification)
  }
}
