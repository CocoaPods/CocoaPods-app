import Cocoa

/// These are simple models for the Podfile Metadata.
/// Until there is a need to break them out into full models with methods etc, I'm OK
/// with keeping them scoped within the MetadataViewController

class CPXcodeProject: NSObject {
  var targets = [CPXcodeTarget]()
  var integrationType = "Static Libraries"
  var fileName = "CocoaPods.xcodeproj"
  var filePath = NSURL(fileURLWithPath: "")
  var plugins = [String]()

  var image = NSWorkspace.sharedWorkspace().iconForFileType("xcodeproj")
}

class CPXcodeTarget: NSObject {
  var warnings = "Show all"
  var bundleID = "org.cocoapods.app"
  var platform = "OS X, 10.9"
  var type = "Mac OS X App"
  var name = "CocoaPods"
  var cocoapodsTargets = [String]()
  var icon: NSImage!
}

class CPCocoaPodsTarget: NSObject {
  var pods = [CPPod]()
  var name = ""
}

class CPPod: NSObject {
  let name: String
  let version: String

  init(name: String, version: String) {
    self.name = name
    self.version = version
  }
}

class CPPodfileMetadataViewController: NSViewController {
  var podfileChecker: CPPodfileReflection!
  var xcodeprojects: [CPXcodeProject] = []
  var infoGenerator = CPXcodeInformationGenerator()

  @IBOutlet var metadataDataSource: CPMetadataTableViewDataSource!

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let podfileVC = podfileViewController, project = podfileVC.userProject else {
      return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }

    project.registerForFullMetadata {

      self.infoGenerator.XcodeProjectMetadataFromUserProject(project) { (projects, targets, error) in
        // By not setting, we leave it at the default of "no plugins".
        if (project.podfilePlugins.count > 0) {
          self.metadataDataSource.plugins = project.podfilePlugins.joinWithSeparator(", ")
        }

        self.metadataDataSource.setXcodeProjects(projects, targets:targets)
      }

    }
  }

  @IBAction func openPod(sender: NSButton) {
    let row = metadataDataSource.tableView.rowForView(sender)
    guard let pod = metadataDataSource.tableView(metadataDataSource.tableView, objectValueForTableColumn: nil, row: row) as? CPPod else {
      return print("Index was not a pod")
    }

    CPExternalLinksHelper().openPodWithName(pod.name)
  }
}
