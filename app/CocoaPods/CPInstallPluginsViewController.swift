import Cocoa

class CPInstallPluginsViewController: NSViewController, CPCLITaskDelegate {

  dynamic var pluginsToInstall = [String]()
  // must be DI'd before viewWillAppear
  var userProject: CPUserProject!
  var failed: Bool = false
  var pluginsInstalled: (() -> ())?

  dynamic var installTask: CPCLITask?

  override func viewWillAppear() {
    super.viewWillAppear()

    let gems = pluginsToInstall.joinWithSeparator(" ")
    let command = "plugins install \(gems)"
    failed = false

    installTask = CPCLITask(userProject: userProject, command: command, delegate: self, qualityOfService:.UserInitiated)
    installTask?.run()
  }

  func task(task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    NSLog("Task: \(updatedOutput.string)")
    failed = failed && updatedOutput.string.containsString("ERROR:")
  }

  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var exitButton: NSButton!
  func taskCompleted(task: CPCLITask!) {
    if failed {
      exitButton.title = NSLocalizedString("Exit", comment: "Exit sheet button title")
      titleLabel.stringValue = NSLocalizedString("Failed to Install Plugins", comment: "Failed to Install Plugins")

    } else {
      exitButton.title = NSLocalizedString("Close", comment: "Close sheet button title")
      titleLabel.stringValue = NSLocalizedString("Installed Plugins", comment: "Install plugin title when completed")
      pluginsInstalled?()
    }
  }

  @IBAction func exitTapped(sender: AnyObject) {
    guard let window = view.window else { return }
    view.window?.sheetParent?.endSheet(window)
  }
}
