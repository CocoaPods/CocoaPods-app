import Cocoa

class CPPodfilePluginCoordinator: NSObject {

  init(controller:CPPodfileViewController) {
    self.controller = controller
  }

  var controller: CPPodfileViewController
  var pluginsToInstall = [String]()

  func comparePluginsWithinUserProject(project: CPUserProject) {
    guard let reflection = NSApp.delegate as? CPAppDelegate else {
      return NSLog("App delegate not CPAppDelegate")
    }
    guard let reflector = reflection.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return NSLog("Could not get a reflection service")
    }

    var podfilePlugins = [String]()
    var installedPlugins = [String]()
    let group = dispatch_group_create()

    // Get the installed plugins
    dispatch_group_enter(group)
    reflector.installedPlugins { plugins, error in
      installedPlugins = plugins ?? []
      dispatch_group_leave(group)
    }

    // Get the plugins from the podfile
    dispatch_group_enter(group)
    reflector.pluginsFromPodfile(project.contents) { plugins, error in
      podfilePlugins = plugins ?? []
      dispatch_group_leave(group)
    }

    // Once both asynchronous operations are completed
    // figure out if we have all the required gems
    // and if not, show the message

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      let shouldRecommendInstall = Set(installedPlugins).isSupersetOf(podfilePlugins) == false
      if shouldRecommendInstall == false || podfilePlugins.count == 0 {
        return;
      }

      self.pluginsToInstall = podfilePlugins.filter { !installedPlugins.contains($0) }

      dispatch_async(dispatch_get_main_queue()) {
        let inflectedPlugin = (self.pluginsToInstall.count == 1) ? "plugin" : "plugins"
        self.controller.showWarningLabelWithSender("You need to install \(self.pluginsToInstall.count) \(inflectedPlugin) for this Podfile", actionTitle: "Install", target: self, action: #selector(CPPodfilePluginCoordinator.showInstaller), animated:true)
      }
    }
  }

  func showInstaller() {
    guard let storyboard = controller.storyboard else { return }
    guard let windowController = storyboard.instantiateControllerWithIdentifier("InstallPlugins") as? NSWindowController else { return }
    guard let missingPluginInstaller = windowController.contentViewController as? CPInstallPluginsViewController else { return }

    missingPluginInstaller.pluginsToInstall = self.pluginsToInstall
    missingPluginInstaller.userProject = controller.userProject
    missingPluginInstaller.pluginsInstalled = {
      self.controller.hideWarningLabel()
    }

    guard let sheet = windowController.window else { return }
    controller.view.window?.beginSheet(sheet, completionHandler: nil)
  }
}
