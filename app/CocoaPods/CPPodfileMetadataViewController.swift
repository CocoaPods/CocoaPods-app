import Cocoa

// Temp for now

struct CPXcodeProject  {
  var targets = [CPTarget]()
}

struct CPTarget  {
  var pods = [CPPod]()
}

struct CPPod  {
  let name: String
  let version: String
}

class CPPodfileMetadataViewController: NSViewController {
  var podfileChecker: CPPodfileReflection!
  var xcodeprojects: [CPXcodeProject] = []

  override func viewWillAppear() {
    super.viewWillAppear()

  }

}
