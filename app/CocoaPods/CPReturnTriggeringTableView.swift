import Cocoa

/// We want to have return trigger the double click 
/// action on a cell.

class CPReturnTriggeringTableView: NSTableView {

  override func keyDown(event: NSEvent) {
    let returnKeycode = 36

    if Int(event.keyCode) == returnKeycode {
      sendAction(doubleAction, to: target)
      return
    }

    super.keyDown(event)
  }

}
