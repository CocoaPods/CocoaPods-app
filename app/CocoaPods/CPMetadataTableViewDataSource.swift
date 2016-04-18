import Cocoa

class CPMetadataTableViewDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {

  var flattenedXcodeProject: [AnyObject] = []
  var plugins = ["No plugins"]

  @IBOutlet weak var tableView: NSTableView!

  func setXcodeProjects(projects:[CPXcodeProject], targets:[CPCocoaPodsTarget]) {
    flattenedXcodeProject = flattenXcodeProjects(projects, targets:targets)
    tableView.reloadData()
  }

  // TODO: I bet someone could code-golf this pretty well
  private func flattenXcodeProjects(projects:[CPXcodeProject], targets:[CPCocoaPodsTarget]) -> [AnyObject] {
    var flattenedObjects: [AnyObject] = []

    for xcodeproject in projects {
      flattenedObjects.append(xcodeproject)

      for target in xcodeproject.targets {
        flattenedObjects.append(target)

        for targetName in target.cocoapodsTargets {
          targets.filter { $0.name == targetName }.forEach { pod_target in
            for pod in pod_target.pods {
              flattenedObjects.append(pod)
            }
          }
        }
        flattenedObjects.append("spacer")
      }
    }
    return flattenedObjects
  }

  // Nothing is selectable except the buttons
  func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    return false
  }

  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return flattenedXcodeProject.count
  }

  // Allows the UI to be set up via bindings
  func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
    return flattenedXcodeProject[row]
  }

  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let data = flattenedXcodeProject[row]
    if let xcodeproj = data as? CPXcodeProject {
      return tableView.makeViewWithIdentifier("xcodeproject_metadata", owner: xcodeproj)

    } else if let target = data as? CPXcodeTarget {
      return tableView.makeViewWithIdentifier("target_metadata", owner: target)

    } else if let pod = data as? CPPod {
      return tableView.makeViewWithIdentifier("pod_metadata", owner: pod)

    } else if let _ = data as? NSString {
      return tableView.makeViewWithIdentifier("spacer", owner: nil)
    }

    print("Should not have data unaccounted for in the flattened xcode project", terminator: "");
    return nil
  }

  func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    let data = flattenedXcodeProject[row]
    if let _ = data as? CPXcodeProject {
      return 120

    } else if let _ = data as? CPXcodeTarget {
      return 150

    } else if let _ = data as? CPPod {
      return 30

    // Spacer
    } else if let _ = data as? NSString {
      return 30
    }

    return 0
  }
}
