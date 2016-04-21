import Cocoa

class CPSourceReposViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

  var flattenedReposAndTitles: [AnyObject] = []
  @IBOutlet weak var tableView: NSTableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.reloadData()
  }

  func setActiveSourceRepos(activeRepos:[CPSourceRepo], inactiveRepos:[CPSourceRepo]) {
    var repos:[AnyObject] = activeRepos.isEmpty ? [] : ["Sources Repos in this Podfile"]
    for repo in activeRepos {
      repos.append(repo)
    }

    if !inactiveRepos.isEmpty {
      repos.append("Other Source Repos")

      for repo in inactiveRepos {
        repos.append(repo)
      }
    }
    
    self.flattenedReposAndTitles = repos
  }

  // Nothing is selectable except the buttons
  func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    return false
  }

  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return flattenedReposAndTitles.count
  }

  // Allows the UI to be set up via bindings
  func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
    return flattenedReposAndTitles[row]
  }

  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let data = flattenedReposAndTitles[row]
    if let repo = data as? CPSourceRepo {
      return tableView.makeViewWithIdentifier("repo", owner: repo)

    } else if let title = data as? NSString {
      return tableView.makeViewWithIdentifier("title", owner: title)
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

  func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
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
