import Cocoa

enum InstallActionType {
  case Install(options: InstallOptions)
  case Update(options: InstallOptions)
}

struct InstallOptions {
  let verbose: Bool
  let repoUpdate: Bool

  var commandOptions : String {
    var string = ""
    if verbose { string += "--verbose " }
    if repoUpdate { string += "--repo-update " }
    return string
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
      executeTaskWithCommand("install \(options.commandOptions)")
    case .Update(let options):
      executeTaskWithCommand("update \(options.commandOptions)")
    }
  }

  private func executeTaskWithCommand(command: String) {
    task = CPCLITask(userProject: userProject, command: command, delegate: self, qualityOfService: .UserInitiated)
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
        notifyWithTitle(NSLocalizedString("WORKSPACE_GENERATED_NOTIFICATION_TITLE", comment: ""))
      } else {
        notifyWithTitle(NSLocalizedString("WORKSPACE_FAILED_GENERATION_NOTIFICATION_TITLE", comment: ""))
      }
    }
  }

  private func notifyWithTitle(title: String) {
    let notification = NSUserNotification()
    notification.title = title
    if let path = userProject.fileURL?.relativePath {
      notification.subtitle = (path as NSString).stringByAbbreviatingWithTildeInPath
    }
    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
  }
}
