import Cocoa

class CPPodFileWindowViewController: NSWindowController {
  override func awakeFromNib() {
    // NOTE: Circumvent bug where setting the value only in
    // the interface buider has no effect.
    // See: http://stackoverflow.com/a/25254575/1892473
    windowFrameAutosaveName = "CocoaPodsEditorWindow"
  }
}
