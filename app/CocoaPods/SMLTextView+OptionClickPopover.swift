import Fragaria
import WebKit

extension SMLTextView {
  
  private struct AssociatedKeys {
    static var optionClickPopover = "org.cocoapods.CocoaPods.optionClickPopover"
    static var selectedPodRange = "org.cocoapods.CocoaPods.selectedPodRange"
    static var hoveredPodRange = "org.cocoapods.CocoaPods.hoveredPodRange"
    static var optionKeyDown = "org.cocoapods.CocoaPods.optionKeyDown"
  }
  
  var optionClickPopover: NSPopover? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.optionClickPopover) as? NSPopover
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.optionClickPopover, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  // The pod name range where the NSPopover currently is
  var selectedPodRange: NSRange? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.selectedPodRange) as? NSRange
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.selectedPodRange, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  // The pod name range currently hovered with option key down (excluding when that range is the same
  // as the one where the popover is)
  var hoveredPodRange: NSRange? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.hoveredPodRange) as? NSRange
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.hoveredPodRange, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var isOptionKeyDown: Bool {
    get {
      return (objc_getAssociatedObject(self, &AssociatedKeys.optionKeyDown) as? Bool) ?? false
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.optionKeyDown, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  
  public override func mouseMoved(theEvent: NSEvent) {
    super.mouseMoved(theEvent)
    
    guard theEvent.modifierFlags.contains(.AlternateKeyMask) else {
      return
    }
    processPodMouseHover()
  }
  
  public override func mouseDown(theEvent: NSEvent) {
    super.mouseDown(theEvent)
    
    guard theEvent.modifierFlags.contains(.AlternateKeyMask) else {
      return
    }
    quickLookWithEvent(theEvent)
  }
  
  public override func quickLookWithEvent(event: NSEvent) {
    guard let pod = checkForPodNameBelowMouseLocation() else {
      optionClickPopover?.close()
      return
    }
    
    hoveredPodRange = nil
    
    showPodPopover(forPodWithName: pod.podName, atRange: pod.location)
    updateUnderlineStyle(forPodAtRange: pod.location)
    selectedPodRange = pod.location
  }
  
  public override func flagsChanged(theEvent: NSEvent) {
    if theEvent.modifierFlags.contains(.AlternateKeyMask) {
      processPodMouseHover()
      isOptionKeyDown = true
      
    } else if isOptionKeyDown {
      removeUnderlineStyle(forPodAtRange: hoveredPodRange)
      hoveredPodRange = nil
      isOptionKeyDown = false
    }
    
    super.flagsChanged(theEvent)
  }
  
  private func processPodMouseHover() {
    removeUnderlineStyle(forPodAtRange: hoveredPodRange)
    hoveredPodRange = nil
    
    guard let pod = checkForPodNameBelowMouseLocation() else {
      return
    }
    
    updateUnderlineStyle(forPodAtRange: pod.location)
    if selectedPodRange == nil || selectedPodRange!.location != pod.location.location {
      hoveredPodRange = pod.location
    }
  }
  
  private func checkForPodNameBelowMouseLocation() -> (podName: String, location: NSRange)? {
    guard let string = string else {
      return nil
    }
    
    let hoveredCharIndex = characterIndexForPoint(NSEvent.mouseLocation())
    let lineRange = (string as NSString).lineRangeForRange(NSRange(location: hoveredCharIndex, length: 0))
    let line = (string as NSString).substringWithRange(lineRange)
    let hoveredCharLineIndex = hoveredCharIndex - lineRange.location
    
    guard let hoveredChar = (line as NSString).substringFromIndex(hoveredCharLineIndex).characters.first
      where hoveredChar != "\n" && hoveredChar != "'" && hoveredChar != "\"" && hoveredCharLineIndex > 0 else {
        return nil
    }
    
    var podStartIndex = -1, podEndIndex = -1
    
    // Starting at the mouse location...
    
    // Iterate to the right of the text line in search of the first occurrence of a " or '
    // →
    let rightSideRange = NSRange(location: hoveredCharLineIndex, length: line.characters.count - hoveredCharLineIndex)
    for (index, char) in (line as NSString).substringWithRange(rightSideRange).characters.enumerate() {
      if char == "'" || char == "\"" {
        podEndIndex = hoveredCharLineIndex + index
        break
      }
    }
    
    // Iterate to the left of the text line in search of the first occurence of a " or '
    // ←
    let leftSideRange = NSRange(location: 0, length: hoveredCharLineIndex)
    for (index, char) in (line as NSString).substringWithRange(leftSideRange).characters.reverse().enumerate() {
      if char == "'" || char == "\"" {
        podStartIndex = hoveredCharLineIndex - index
        break
      }
    }
    
    guard podStartIndex >= 0 && podEndIndex >= 0 &&
      (line as NSString).substringWithRange(NSRange(location: 0, length: podStartIndex - 1)).trim().hasSuffix("pod") else {
        return nil
    }
    
    // We need to update the cursor to be inside the pod name so the `autoCompleteDelegate`
    // gets the autocompletions from the `CPPodfileEditorViewController`
    setSelectedRange(NSRange(location: hoveredCharIndex, length: 0))
    
    let podName = (line as NSString).substringWithRange(NSRange(location: podStartIndex, length: podEndIndex - podStartIndex))
    guard let _ = autoCompleteDelegate.completions().indexOf({ ($0 as? String) == podName }) else {
      return nil
    }
    
    let podNameRange = NSRange(location: lineRange.location + podStartIndex, length: podEndIndex - podStartIndex)
    return (podName, podNameRange)
  }
  
  private func updateUnderlineStyle(forPodAtRange range: NSRange) {
    textStorage?.beginEditing()
    textStorage?.addAttributes([
      NSUnderlineStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue),
      NSUnderlineColorAttributeName: CPFontAndColourGateKeeper().cpLinkRed
      ], range: range)
    textStorage?.endEditing()
  }
  
  private func removeUnderlineStyle(forPodAtRange range: NSRange?) {
    guard let range = range else { return }
    
    textStorage?.beginEditing()
    textStorage?.removeAttribute(NSUnderlineStyleAttributeName, range: range)
    textStorage?.endEditing()
  }
  
  private func resetUnderlineStyles() {
    removeUnderlineStyle(forPodAtRange: hoveredPodRange)
    hoveredPodRange = nil
    
    removeUnderlineStyle(forPodAtRange: selectedPodRange)
    selectedPodRange = nil
  }
  
  private func showPodPopover(forPodWithName podName: String, atRange: NSRange) {
    guard let window = window, let string = string,
      let podURL = NSURL(string: "https://cocoapods.org/pods/\(podName)"),
      let customCSSFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingString("/CocoaPods.css") else {
        return
    }
    
    optionClickPopover?.close()
    
    let webView = WebView(frame: NSRect(x: 0, y: 0, width: 320, height: 350))
    webView.wantsLayer = true
    webView.policyDelegate = self
    webView.preferences.userStyleSheetEnabled = true
    webView.preferences.userStyleSheetLocation = NSURL(fileURLWithPath: customCSSFilePath)
    webView.mainFrame.loadRequest(NSURLRequest(URL: podURL))
    
    let popoverViewController = NSViewController()
    popoverViewController.view = webView
    
    var podNameRect = firstRectForCharacterRange(atRange, actualRange: nil)
    podNameRect = window.convertRectFromScreen(podNameRect)
    podNameRect = convertRect(podNameRect, toView: nil)
    podNameRect.size.width = 1
    
    // We use the width of the range starting at the beginning of the line until the middle of the pod name
    // as the x coordinate for the popover (the popover is always centered to the pod name, no matter
    // where the option-click/three finger tap occurred)
    let lineRange = (string as NSString).lineRangeForRange(atRange)
    let startToMiddlePodRange =
      NSRange(location: lineRange.location,
              length: atRange.location - lineRange.location + atRange.length / 2 + (atRange.length % 2 == 0 ? 0 : 1))
    podNameRect.origin.x = firstRectForCharacterRange(startToMiddlePodRange, actualRange: nil).width

    let popover = NSPopover()
    popover.contentViewController = popoverViewController
    popover.behavior = .Transient
    popover.delegate = self
    popover.showRelativeToRect(podNameRect, ofView: self, preferredEdge: .MaxY)
    
    optionClickPopover = popover
  }
  
  public override func shouldChangeTextInRange(affectedCharRange: NSRange, replacementString: String?) -> Bool {
    resetUnderlineStyles()
    return super.shouldChangeTextInRange(affectedCharRange, replacementString: replacementString)
  }
}

// MARK: - NSPopoverDelegate
extension SMLTextView: NSPopoverDelegate {

  public func popoverWillClose(notification: NSNotification) {
    resetUnderlineStyles()
  }
}

// MARK: - WebPolicyDelegate
extension SMLTextView: WebPolicyDelegate {
  
  public func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!,
                      request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
    if let _ = actionInformation?[WebActionElementKey],
      let externalURL = actionInformation[WebActionOriginalURLKey] as? NSURL {
      // An action has ocurred (link click): redirect the user to the browser
      listener.ignore()
      NSWorkspace.sharedWorkspace().openURL(externalURL)
    } else {
      // Loading the CocoaPods pod page: accept
      listener.use()
    }
  }
}

