import Cocoa

/// UIVIewController to represent the Podfile editor
/// It's scope is keeping track of the user project,
/// handling / exposing tabs and providing a central
/// access place for mutable state within the Podfile
/// section of CocoaPods.app

/// TODO:
///  setting tabs via the images
///  cmd + 1,2,3
///  add commands for `pod install` / `update`


class CPPodfileViewController: NSViewController, NSTabViewDelegate {

  var userProject:CPUserProject!
  @IBOutlet var contentView:NSView!
  dynamic var installAction: CPInstallAction!

  @IBOutlet weak var actionTitleLabel: NSTextField!
  @IBOutlet weak var documentIconContainer: NSView!

  override func viewWillAppear() {

    // The userProject is DI'd in after viewDidLoad
    installAction = CPInstallAction(userProject: userProject)

    // The view needs to be added to a window before we can use
    // the window to pull out to the document icon from the window

    guard let window = view.window as? CPModifiedDecorationsWindow, let documentIcon = window.documentIconButton else {
      return print("Window type is not CPModifiedDecorationsWindow")
    }

    documentIcon.frame = documentIcon.bounds
    documentIconContainer.addSubview(documentIcon)
  }

  var tabController: NSTabViewController {
    return childViewControllers.filter { $0.isKindOfClass(NSTabViewController) }.first! as! NSTabViewController
  }

  @IBAction func install(obj: AnyObject) {
    installAction.performAction(.Install(verbose: false))
    showConsoleTab(self)
  }

  @IBAction func showEditorTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 0
  }

  @IBAction func showConsoleTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 2
  }

  @IBAction func showInformationTab(sender: AnyObject) {
    tabController.selectedTabViewItemIndex = 1
  }
}

extension NSViewController {

  /// Recurse the parentViewControllers till we find a CPPodfileViewController
  /// this lets child view controllers access this class for shared state.

  var podfileViewController: CPPodfileViewController? {

    guard let parent = self.parentViewController else { return nil }
    if let appVC = parent as? CPPodfileViewController {
      return appVC
    } else {
      return parent.podfileViewController
    }
  }
}