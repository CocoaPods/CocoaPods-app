import Cocoa

// Temp for now ?

class CPXcodeProject: NSObject {
  var targets = [CPTarget]()
  var integrationType = "Static Libraries"
  var warnings = "Show all"
  var fileName = "CocoaPods.xcodeproj"
}

class CPTarget: NSObject {
  var pods = [CPPod]()
  var bundleID = "org.cocoapods.app"
  var platform = "OS X, 10.9"
  var type = "Mac OS X App"
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

  @IBOutlet var metadataDataSource: CPMetadataTableViewDataSource!

  override func viewWillAppear() {
    super.viewWillAppear()

    let pod = CPPod(name: "Pod 1", version: "1.0.0")
    let pod2 = CPPod(name: "Pod 2", version: "1.0.0")

    let xcodeproj = CPXcodeProject()
    let target = CPTarget()
    target.pods = [pod, pod2]
    xcodeproj.targets = [target]

    metadataDataSource.setXcodeProjects([xcodeproj])
  }

}
