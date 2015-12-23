import Cocoa

class CPMetadataTableViewDataSource: NSObject, NSTableViewDataSource {
  var xcodeProjects: [CPXcodeProject] = []
  var flattenedXcodeProject: [AnyObject] = []

  func flattenXcodeProjects(projects:[CPXcodeProject]) -> [AnyObject] {
    var
  }

  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    var rows = 0
    for xcodeproject in xcodeProjects {
      rows += 1
      for target in xcodeproject.targets {
        rows += 1
        for pod in target.pods {
          rows += 1
        }
      }

    }
    return rows
  }

  func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
    return nil;
  }

}
