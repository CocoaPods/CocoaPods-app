import Cocoa

class CPMenuRepoUpdateDirector: NSObject {
  let repoCoordinator = CPSourceRepoCoordinator()

  @IBOutlet weak var sourceReposMenu: NSMenu!

  override func awakeFromNib() {
    super.awakeFromNib()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(lookForSources), name: NSApplicationDidFinishLaunchingNotification, object: nil)
  }

  func lookForSources() {
    repoCoordinator.getSourceRepos(createMenuForSources)
  }

  func createMenuForSources(sources: [CPSourceRepo]) {
    sourceReposMenu.removeAllItems()

    let menuItems = sources.map(menuItemForRepo)
    for menu in menuItems { sourceReposMenu.addItem(menu) }
  }

  func menuItemForRepo(source: CPSourceRepo) -> NSMenuItem {
    return NSMenuItem(title: source.name, action: "ok", keyEquivalent: "e")
  }
}
