import Fragaria
import WebKit

extension SMLTextView {
  
  fileprivate struct AssociatedKeys {
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
  
  
  open override func mouseMoved(with theEvent: NSEvent) {
    super.mouseMoved(with: theEvent)
    
    guard theEvent.modifierFlags.contains(NSEvent.ModifierFlags.option) else {
      return
    }
    processPodMouseHover()
  }
  
  open override func mouseDown(with theEvent: NSEvent) {
    super.mouseDown(with: theEvent)
    
    guard theEvent.modifierFlags.contains(NSEvent.ModifierFlags.option) else {
      return
    }
    quickLook(with: theEvent)
  }
  
  open override func quickLook(with event: NSEvent) {
    guard let pod = checkForPodNameBelowMouseLocation() else {
      optionClickPopover?.close()
      return
    }
    
    hoveredPodRange = nil
    
    showPodPopover(forPodWithName: pod.podName, atRange: pod.location)
    updateUnderlineStyle(forPodAtRange: pod.location)
    selectedPodRange = pod.location
  }
  
  open override func flagsChanged(with theEvent: NSEvent) {
    if theEvent.modifierFlags.contains(NSEvent.ModifierFlags.option) {
      processPodMouseHover()
      isOptionKeyDown = true
      
    } else if isOptionKeyDown {
      removeUnderlineStyle(forPodAtRange: hoveredPodRange)
      hoveredPodRange = nil
      isOptionKeyDown = false
    }
    
    super.flagsChanged(with: theEvent)
  }
  
  fileprivate func processPodMouseHover() {
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
  
  fileprivate func checkForPodNameBelowMouseLocation() -> (podName: String, location: NSRange)? {    
    let hoveredCharIndex = characterIndex(for: NSEvent.mouseLocation)
    let lineRange = (string as NSString).lineRange(for: NSRange(location: hoveredCharIndex, length: 0))
    let line = (string as NSString).substring(with: lineRange)
    let hoveredCharLineIndex = hoveredCharIndex - lineRange.location
    
    guard let hoveredChar = (line as NSString).substring(from: hoveredCharLineIndex).characters.first, hoveredChar != "\n" && hoveredChar != "'" && hoveredChar != "\"" && hoveredCharLineIndex > 0 else {
        return nil
    }
    
    var podStartIndex = -1, podEndIndex = -1
    
    // Starting at the mouse location...
    
    // Iterate to the right of the text line in search of the first occurrence of a " or '
    // →
    let rightSideRange = NSRange(location: hoveredCharLineIndex, length: line.characters.count - hoveredCharLineIndex)
    for (index, char) in (line as NSString).substring(with: rightSideRange).characters.enumerated() {
      if char == "'" || char == "\"" {
        podEndIndex = hoveredCharLineIndex + index
        break
      }
    }
    
    // Iterate to the left of the text line in search of the first occurence of a " or '
    // ←
    let leftSideRange = NSRange(location: 0, length: hoveredCharLineIndex)
    for (index, char) in (line as NSString).substring(with: leftSideRange).characters.reversed().enumerated() {
      if char == "'" || char == "\"" {
        podStartIndex = hoveredCharLineIndex - index
        break
      }
    }
    
    guard podStartIndex >= 0 && podEndIndex >= 0 &&
      (line as NSString).substring(with: NSRange(location: 0, length: podStartIndex - 1)).trim().hasSuffix("pod") else {
        return nil
    }
    
    // We need to update the cursor to be inside the pod name so the `autoCompleteDelegate`
    // gets the autocompletions from the `CPPodfileEditorViewController`
    setSelectedRange(NSRange(location: hoveredCharIndex, length: 0))
    
    let podName = (line as NSString).substring(with: NSRange(location: podStartIndex, length: podEndIndex - podStartIndex))
    guard let _ = autoCompleteDelegate.completions().index(where: { ($0 as? String) == podName }) else {
      return nil
    }
    
    let podNameRange = NSRange(location: lineRange.location + podStartIndex, length: podEndIndex - podStartIndex)
    return (podName, podNameRange)
  }
  
  fileprivate func updateUnderlineStyle(forPodAtRange range: NSRange) {
    textStorage?.beginEditing()
    textStorage?.addAttributes([
      NSAttributedStringKey.underlineStyle: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int),
      NSAttributedStringKey.underlineColor: CPFontAndColourGateKeeper().cpLinkRed
      ], range: range)
    textStorage?.endEditing()
  }
  
  fileprivate func removeUnderlineStyle(forPodAtRange range: NSRange?) {
    guard let range = range else { return }
    
    textStorage?.beginEditing()
    textStorage?.removeAttribute(NSAttributedStringKey.underlineStyle, range: range)
    textStorage?.endEditing()
  }
  
  fileprivate func resetUnderlineStyles() {
    removeUnderlineStyle(forPodAtRange: hoveredPodRange)
    hoveredPodRange = nil
    
    removeUnderlineStyle(forPodAtRange: selectedPodRange)
    selectedPodRange = nil
  }
  
  fileprivate func showPodPopover(forPodWithName podName: String, atRange: NSRange) {
    guard let window = window,
      let podURL = URL(string: "https://cocoapods.org/pods/\(podName)") else {
        return
    }
    let customCSSFilePath = (Bundle.main.resourcePath)! + "/CocoaPods.css"
    
    optionClickPopover?.close()
    
    let webView = WebView(frame: NSRect(x: 0, y: 0, width: 320, height: 350))
    webView.wantsLayer = true
    webView.policyDelegate = self
    webView.preferences.userStyleSheetEnabled = true
    webView.preferences.userStyleSheetLocation = URL(fileURLWithPath: customCSSFilePath)
    webView.mainFrame.load(URLRequest(url: podURL))
    
    let popoverViewController = NSViewController()
    popoverViewController.view = webView
    
    var podNameRect = firstRect(forCharacterRange: atRange, actualRange: nil)
    podNameRect = window.convertFromScreen(podNameRect)
    podNameRect = convert(podNameRect, to: nil)
    podNameRect.size.width = 1
    
    // We use the width of the range starting at the beginning of the line until the middle of the pod name
    // as the x coordinate for the popover (the popover is always centered to the pod name, no matter
    // where the option-click/three finger tap occurred)
    let lineRange = (string as NSString).lineRange(for: atRange)
    let startToMiddlePodRange =
      NSRange(location: lineRange.location,
              length: atRange.location - lineRange.location + atRange.length / 2 + (atRange.length % 2 == 0 ? 0 : 1))
    podNameRect.origin.x = firstRect(forCharacterRange: startToMiddlePodRange, actualRange: nil).width

    let popover = NSPopover()
    popover.contentViewController = popoverViewController
    popover.behavior = .transient
    popover.delegate = self
    popover.show(relativeTo: podNameRect, of: self, preferredEdge: .maxY)
    
    optionClickPopover = popover
  }
  
  open override func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
    resetUnderlineStyles()
    return super.shouldChangeText(in: affectedCharRange, replacementString: replacementString)
  }
}

// MARK: - NSPopoverDelegate
extension SMLTextView: NSPopoverDelegate {

  public func popoverWillClose(_ notification: Notification) {
    resetUnderlineStyles()
  }
}

// MARK: - WebPolicyDelegate
extension SMLTextView: WebPolicyDelegate {
  
  public func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [AnyHashable: Any]!,
                      request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
    if let _ = actionInformation?[WebActionElementKey],
      let externalURL = actionInformation[WebActionOriginalURLKey] as? URL {
      // An action has ocurred (link click): redirect the user to the browser
      listener.ignore()
      NSWorkspace.shared.open(externalURL)
    } else {
      // Loading the CocoaPods pod page: accept
      listener.use()
    }
  }
}

