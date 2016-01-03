import Cocoa

// Temp for now ?

class CPXcodeProject: NSObject {
  var targets = [CPXcodeTarget]()
  var integrationType = "Static Libraries"
  var fileName = "CocoaPods"
  var filePath = NSURL(fileURLWithPath: "")
  var image = NSWorkspace.sharedWorkspace().iconForFileType("xcodeproj")
  var plugins = ["CocoaPods-Keys"]
}

class CPXcodeTarget: NSObject {
  var pods = [CPPod]()
  var warnings = "Show all"
  var bundleID = "org.cocoapods.app"
  var platform = "OS X, 10.9"
  var type = "Mac OS X App"
  var name = "OK"
  var cocoapodsTargets = [String]()
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

    infoGenerator.XcodeProjectMetadataFromUserProject(project) { (projects, targets, error)  in
      self.metadataDataSource.setXcodeProjects(projects, targets:targets)
    }

  }

}
