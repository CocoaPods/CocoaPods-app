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
    titleLabel.stringValue = ~"plugins installing message"

    let command = "plugins install"
    failed = false

    installTask = CPCLITask(userProject: userProject, command: command, arguments: pluginsToInstall, delegate: self, qualityOfService:.UserInitiated)
    installTask?.run()
  }

  func task(task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    failed = failed && updatedOutput.string.containsString("ERROR:")
  }

  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var exitButton: NSButton!
  func taskCompleted(task: CPCLITask!) {
    if failed {
      exitButton.title = ~"Exit"
      titleLabel.stringValue = ~"plugin failed to install message"

    } else {
      exitButton.title = ~"Close"
      titleLabel.stringValue = ~"plugins all installed message"
      pluginsInstalled?()
    }
  }

  @IBAction func exitTapped(sender: AnyObject) {
    guard let window = view.window else { return }
    view.window?.sheetParent?.endSheet(window)
  }
}
