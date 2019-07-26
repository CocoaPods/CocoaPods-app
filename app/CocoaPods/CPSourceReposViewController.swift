import Cocoa

class CPSourceReposViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

  var flattenedReposAndTitles: [Any] = []
  @IBOutlet weak var tableView: NSTableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.reloadData()
  }

  func setActiveSourceRepos(_ activeRepos:[CPSourceRepo], inactiveRepos:[CPSourceRepo]) {
    var repos: [Any] = activeRepos.isEmpty ? [] : ["Sources Repos in this Podfile"]
    for repo in activeRepos {
      repos.append(repo)
    }

    if !inactiveRepos.isEmpty {
      repos.append("Other Source Repos" as AnyObject)

      for repo in inactiveRepos {
        repos.append(repo)
      }
    }
    
    self.flattenedReposAndTitles = repos
  }

  // Nothing is selectable except the buttons
  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    return false
  }

  func numberOfRows(in tableView: NSTableView) -> Int {
    return flattenedReposAndTitles.count
  }

  // Allows the UI to be set up via bindings
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    return flattenedReposAndTitles[row]
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let data = flattenedReposAndTitles[row]
    if let repo = data as? CPSourceRepo {
      return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "repo"), owner: repo)

    } else if let title = data as? NSString {
      return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "title"), owner: title)
    }

    print("Should not have data unaccounted for in the flattened repos");
    return nil
  }

  func heightOfData() -> CGFloat {
    var height = CGFloat(0)
    for data in flattenedReposAndTitles {
      if let _ = data as? CPSourceRepo {
        height += 63

      } else if let _ = data as? NSString {
        height += 61
      }
    }
    return height + 20
  }

  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    let data = flattenedReposAndTitles[row]
    if let _ = data as? CPSourceRepo {
      return 63

    } else if let _ = data as? NSString {
      return 61
    }

    print("Should not have data unaccounted for in the flattened repos");
    return 0
  }
}
