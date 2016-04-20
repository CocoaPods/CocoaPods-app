import Cocoa
import Sparkle

class CPSparkleDelegate: NSObject, SUUpdaterDelegate {
  @IBOutlet var toggleSparkleMenuItem: NSMenuItem!

  let disableKey = "CPDisableSparkleUpdates"

  override func awakeFromNib() {
    super.awakeFromNib()
    updateMenuItem()
  }

  @IBAction func toggleSparkleUpdates(button: AnyObject) {
    let defaults = NSUserDefaults.standardUserDefaults()
    let disabled = defaults.boolForKey(disableKey)
    defaults.setBool(!disabled, forKey: disableKey)
    defaults.synchronize()

    updateMenuItem()
  }

  func updateMenuItem() {
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.boolForKey(disableKey) {
      toggleSparkleMenuItem.title = "Re-enable Sparkle Updates"
    } else {
      toggleSparkleMenuItem.title = "Disable Sparkle Updates"
    }
  }

  func updaterMayCheckForUpdates(updater: SUUpdater!) -> Bool {
    let defaults = NSUserDefaults.standardUserDefaults()
    let disabled = defaults.boolForKey(disableKey)
    return !disabled
  }

}
