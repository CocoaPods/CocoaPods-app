import Foundation

class CPXcodeProjectCell: NSTableCellView {
  @IBOutlet weak var projectOpenButton: NSButton!
  
  override func awakeFromNib() {
    let rightClickGesture = NSClickGestureRecognizer(target: self, action: #selector(CPXcodeProjectCell.contextualMenuForProject(_:)))
    rightClickGesture.buttonMask = 0x2 // right mouse
    projectOpenButton.addGestureRecognizer(rightClickGesture)
  }
  
  func contextualMenuForProject(gestureRecognizer: NSGestureRecognizer) {
    let menu = NSMenu(title: "title")
    let showMenuItem = NSMenuItem()
    showMenuItem.title = "Show in Finder"
    showMenuItem.target = self
    showMenuItem.action = #selector(CPXcodeProjectCell.showInFinder(_:))
    menu.addItem(showMenuItem)
    let openMenuItem = NSMenuItem()
    openMenuItem.title = "Open Project"
    openMenuItem.target = self
    openMenuItem.action = #selector(CPXcodeProjectCell.openProject)
    menu.addItem(openMenuItem)
    menu.popUpMenuPositioningItem(nil, atLocation: NSEvent.mouseLocation(), inView: nil)
  }
  
  @IBAction func showInFinder(sender: AnyObject) {
    guard let project = objectValue as? CPXcodeProject else {
      return Swift.print("objectValue is not CPXcodeProject")
    }
    
    NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([project.filePath])
  }
  
  func openProject() {
    guard let project = objectValue as? CPXcodeProject else {
      return Swift.print("objectValue is not CPXcodeProject")
    }
    
    NSWorkspace.sharedWorkspace().openFile(project.filePath.path!)
  }
  
}