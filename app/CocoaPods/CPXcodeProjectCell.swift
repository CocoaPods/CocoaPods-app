import Foundation

class CPXcodeProjectCell: NSTableCellView {
  @IBOutlet weak var projectOpenButton: NSButton!
  
  override func awakeFromNib() {
    let rightClickGesture = NSClickGestureRecognizer(target: self, action: Selector("contextualMenuForProject:"))
    rightClickGesture.buttonMask = 0x2 // right mouse
    projectOpenButton.addGestureRecognizer(rightClickGesture)
//    projectOpenButton.target = self
//    projectOpenButton.action = Selector("openProject")
  }
  
  func contextualMenuForProject(gestureRecognizer: NSGestureRecognizer) {
    let menu = NSMenu(title: "title")
    let openMenuItem = NSMenuItem()
    openMenuItem.title = "Open Project"
    openMenuItem.target = self
    openMenuItem.action = Selector("openProject:")
    menu.addItem(openMenuItem)
    let showMenuItem = NSMenuItem()
    showMenuItem.title = "Show in Finder"
    showMenuItem.target = self
    showMenuItem.action = Selector("showInFinder")
    menu.addItem(showMenuItem)
    menu.popUpMenuPositioningItem(nil, atLocation: NSEvent.mouseLocation(), inView: nil)
  }
  
  func showInFinder() {
    guard let project = objectValue as? CPXcodeProject else {
      return Swift.print("objectValue is not CPXcodeProject")
    }
    
    NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([project.filePath])
  }
  
  @IBAction func openProject(sender: AnyObject) {
    guard let project = objectValue as? CPXcodeProject else {
      return Swift.print("objectValue is not CPXcodeProject")
    }
    
    NSWorkspace.sharedWorkspace().openFile(project.filePath.path!)
  }
  
}