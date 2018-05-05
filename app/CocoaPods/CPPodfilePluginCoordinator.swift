import Cocoa

class CPPodfilePluginCoordinator: NSObject {

  init(controller:CPPodfileViewController) {
    self.controller = controller
  }

  var controller: CPPodfileViewController
  var pluginsToInstall = [String]()

  func comparePluginsWithinUserProject(_ project: CPUserProject) {
    guard let reflection = NSApp.delegate as? CPAppDelegate else {
      return NSLog("App delegate not CPAppDelegate")
    }
    guard let reflector = reflection.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol else {
      return NSLog("Could not get a reflection service")
    }

    var podfilePlugins = [String]()
    var installedPlugins = [String]()
    let group = DispatchGroup()

    // Get the installed plugins
    group.enter()
    reflector.installedPlugins { plugins, error in
      installedPlugins = plugins ?? []
      group.leave()
    }

    // Get the plugins from the podfile
    group.enter()
    reflector.plugins(fromPodfile: project.contents) { plugins, error in
      podfilePlugins = plugins ?? []
      group.leave()
    }

    // Once both asynchronous operations are completed
    // figure out if we have all the required gems
    // and if not, show the message

    group.notify(queue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high)) {
      let shouldRecommendInstall = Set(installedPlugins).isSuperset(of: podfilePlugins) == false
      if shouldRecommendInstall == false || podfilePlugins.count == 0 {
        return;
      }

      self.pluginsToInstall = podfilePlugins.filter { !installedPlugins.contains($0) }

      DispatchQueue.main.async {
        let inflectedPlugin = (self.pluginsToInstall.count == 1) ? "plugin" : "plugins"
        self.controller.showWarningLabelWithSender("You need to install \(self.pluginsToInstall.count) \(inflectedPlugin) for this Podfile", actionTitle: "Install", target: self, action: #selector(CPPodfilePluginCoordinator.showInstaller), animated:true)
      }
    }
  }

  @objc func showInstaller() {
    guard let storyboard = controller.storyboard else { return }
    guard let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "InstallPlugins")) as? NSWindowController else { return }
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
