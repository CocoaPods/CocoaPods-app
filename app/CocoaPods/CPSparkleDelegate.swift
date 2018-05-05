import Cocoa
import Sparkle

class CPSparkleDelegate: NSObject, SUUpdaterDelegate {
  @IBOutlet var toggleSparkleMenuItem: NSMenuItem!

  let disableKey = "CPDisableSparkleUpdates"

  override func awakeFromNib() {
    super.awakeFromNib()
    updateMenuItem()
  }

  @IBAction func toggleSparkleUpdates(_ button: AnyObject) {
    let defaults = UserDefaults.standard
    let disabled = defaults.bool(forKey: disableKey)
    defaults.set(!disabled, forKey: disableKey)
    defaults.synchronize()

    updateMenuItem()
  }

  func updateMenuItem() {
    let defaults = UserDefaults.standard
    if defaults.bool(forKey: disableKey) {
      toggleSparkleMenuItem.title = "Re-enable Sparkle Updates"
    } else {
      toggleSparkleMenuItem.title = "Disable Sparkle Updates"
    }
  }

  func updaterMayCheck(forUpdates updater: SUUpdater!) -> Bool {
    let defaults = UserDefaults.standard
    let disabled = defaults.bool(forKey: disableKey)
    return !disabled
  }

}
