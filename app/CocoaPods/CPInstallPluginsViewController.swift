import Cocoa

class CPInstallPluginsViewController: NSViewController {

  dynamic var pluginsToInstall = [String]()
  // must be DI'd before viewWillAppear
  var userProject: CPUserProject!

  dynamic var installTask: CPCLITask?

  override func viewWillAppear() {
    super.viewWillAppear()

    let gems = pluginsToInstall.joinWithSeparator(" ")
    let command = "plugins install \(gems)"

    installTask = CPCLITask(userProject: userProject, command: command, delegate: nil, qualityOfService:.UserInitiated)
    installTask?.run()
  }

  @IBAction func exitTapped(sender: AnyObject) {
    guard let window = view.window else { return }
    view.window?.sheetParent?.endSheet(window)
  }
}
