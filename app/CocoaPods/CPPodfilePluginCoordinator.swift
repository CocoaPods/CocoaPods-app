import Cocoa

class CPPodfilePluginCoordinator: NSObject {

  init(controller:CPPodfileViewController) {
    self.controller = controller
  }

  var controller: CPPodfileViewController

  func comparePluginsWithinUserProject(project: CPUserProject) {
    guard let reflection = NSApp.delegate as? CPAppDelegate else {
      return NSLog("App delegate not CPAppDelegate")
    }
    guard let reflector = reflection.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return NSLog("Could not get a reflection service")
    }

    var podfilePlugins = [String]()
    var installedPlugins = [String]()
    let group = dispatch_group_create();

    dispatch_group_enter(group)
    reflector.installedPlugins { plugins, error in
      installedPlugins = plugins ?? []
      dispatch_group_leave(group)
    }

    dispatch_group_enter(group)
    reflector.pluginsFromPodfile(project.contents) { plugins, error in
      podfilePlugins = plugins ?? []
      dispatch_group_leave(group)
    }

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      let shouldRecommendInstall = Set(installedPlugins).isSupersetOf(podfilePlugins) == false
      if shouldRecommendInstall == false || podfilePlugins.count == 0 {
        return;
      }

      // install
      NSLog("Install!")
      dispatch_async(dispatch_get_main_queue()) {
        self.controller.showWarningLabelWithSender("You need to install some plugins", target: self, action: "install", animated:true)

      }

    }

  }

}
