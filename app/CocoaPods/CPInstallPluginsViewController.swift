import Cocoa

class CPInstallPluginsViewController: NSViewController, CPCLITaskDelegate {

  dynamic var pluginsToInstall = [String]()
  // must be DI'd before viewWillAppear
  var userProject: CPUserProject!

  dynamic var installTask: CPCLITask?

  override func viewWillAppear() {
    super.viewWillAppear()

    let gems = pluginsToInstall.joinWithSeparator(" ")
    let command = "plugins install \(gems)"

    installTask = CPCLITask(userProject: userProject, command: command, delegate: self, qualityOfService:.UserInitiated)
    installTask?.run()
  }

  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var exitButton: NSButton!
  func taskCompleted(task: CPCLITask!) {
    exitButton.title = NSLocalizedString("Close", comment: "Close sheet button title")
    titleLabel.stringValue = NSLocalizedString("Installed Plugins", comment: "Install plugin title when completed")
  }

  @IBAction func exitTapped(sender: AnyObject) {
    guard let window = view.window else { return }
    view.window?.sheetParent?.endSheet(window)
  }
}
