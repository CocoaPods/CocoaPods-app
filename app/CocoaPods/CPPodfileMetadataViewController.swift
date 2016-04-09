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

  var image = NSImage(imageLiteral: "project")
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
    
  /// Allows us to bind a loading interface.
  dynamic var showingMetadata = false

  @IBOutlet var metadataDataSource: CPMetadataTableViewDataSource!

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let podfileVC = podfileViewController, project = podfileVC.userProject else {
      return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }

    // When all XPC information has been recieved
    project.registerForFullMetadataCallback {

      // Take all podfile metadata dict and make it into the models above
      // this is done async, as it can be a bit of processing time.
      self.infoGenerator.XcodeProjectMetadataFromUserProject(project) { (projects, targets, error) in

        dispatch_async(dispatch_get_main_queue()) {

          // Stop showing loading
          self.showingMetadata = true

          // Setup the tableview
          self.metadataDataSource.plugins = project.podfilePlugins;
          self.metadataDataSource.setXcodeProjects(projects, targets:targets)
        }
      }
    }
  }

  // Opens a pod page in safari
  @IBAction func openPod(sender: NSButton) {
    let row = metadataDataSource.tableView.rowForView(sender)
    guard let pod = metadataDataSource.tableView(metadataDataSource.tableView, objectValueForTableColumn: nil, row: row) as? CPPod else {
      return print("Index was not a pod")
    }

    CPExternalLinksHelper().openPodWithName(pod.name)
  }
}
