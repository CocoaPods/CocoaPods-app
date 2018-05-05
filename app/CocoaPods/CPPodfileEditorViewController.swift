import Cocoa
import Fragaria

/// The Editor's role is to show our Fragaria editor
/// and ensure the changes are sent back upstream to the 
/// CPPodfileViewController's CPUserProject

class CPPodfileEditorViewController: NSViewController, NSTextViewDelegate, SMLAutoCompleteDelegate {

  @IBOutlet var editor: MGSFragariaView!
  var syntaxChecker: CPPodfileReflection!
  let commentSyntax = "# "
  let indentationSyntax = "  "

  var autoCompletions: [String] = {
    if let path = Bundle.main.path(forResource: "Podfile", ofType: "plist"),
      let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
      let words = dict["autocompleteWords"] as? [String] {
        return words
    }
    return []
  }()

  var allPodNames = [String]()
  var selectedLinePodVersions = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()

    let appDelegate = NSApp.delegate as? CPAppDelegate
    (appDelegate?.reflectionService.remoteObjectProxy as AnyObject).allPods { (pods, error) in

      guard let pods = pods else { return }
      self.allPodNames.append(contentsOf: pods)
    }
  }

  // As the userProject is DI'd into the PodfileVC
  // it occurs after the view is set up.

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let podfileVC = podfileViewController, let project = podfileVC.userProject else {
      return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }
    
    project.delegate = self
    editor.becomeFirstResponder()

    editor.isSyntaxColoured = true
    editor.syntaxDefinitionName = "Podfile"
    editor.string = project.contents as NSString

    editor.autoCompleteEnabled = true
    editor.autoCompleteDelay = 0.05

    let settings = CPFontAndColourGateKeeper()
    editor.textFont = settings.defaultFont!
    editor.colourForNumbers = settings.cpGreen
    editor.colourForStrings = settings.cpRed
    editor.colourForComments = settings.cpBrightBrown
    editor.colourForKeywords = settings.cpBlue
    editor.colourForVariables = settings.cpGreen
    editor.colourForInstructions = settings.cpBrightMagenta
    editor.autoCompleteDelegate = self

    editor.currentLineHighlightColour = settings.cpLightYellow
    editor.highlightsCurrentLine = true

    editor.tabWidth = 2
    editor.indentWithSpaces = true
    
    project.undoManager = editor.textView.undoManager
    
    syntaxChecker = CPPodfileReflection(podfileEditorVC: self, fragariaEditor: editor)
    syntaxChecker.textDidChange(Notification(name: Notification.Name(rawValue: ""), object: nil))
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    checkLockfileVersion()
  }

  func checkLockfileVersion() {
    if let lockfilePath = podfileViewController?.userProject.lockfilePath() {
      pullVersionFromLockfile(lockfilePath, completion: { version in
        self.checkForOlderAppVersionWithLockfileVersion(version, completion: { older in
          if let old = older, old.boolValue == true {
            OperationQueue.main.addOperation({ () -> Void in
              self.showWarningForNewerLockfile()
            })
          }
        })
      })
    }
  }

  func appDelegate() -> CPAppDelegate? {
    return NSApp.delegate as? CPAppDelegate
  }

  func appVersion() -> String? {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }

  func pullVersionFromLockfile(_ path: String, completion: @escaping (String?) -> Void) {
    (appDelegate()?.reflectionService.remoteObjectProxy as AnyObject).version(fromLockfile: path, withReply: { (version, error) in
      completion(version)
    })
  }

  func checkForOlderAppVersionWithLockfileVersion(_ version: String?, completion: @escaping (NSNumber?) -> Void) {
    if let lockfileVersion = version, let appVersion = appVersion() {
        (appDelegate()?.reflectionService.remoteObjectProxy as AnyObject).appVersion(appVersion, isOlderThanLockfileVersion: lockfileVersion, withReply: { (result, error) in
          completion(result)
        })
    } else {
      completion(nil)
    }
  }

  func showWarningForNewerLockfile() {
    let title = ~"PODFILE_WINDOW_NEWER_LOCKFILE_ERROR_BUTTON_TITTLE"
    let message = ~"PODFILE_WINDOW_NEWER_LOCKFILE_ERROR"
    podfileViewController?.showWarningLabelWithSender(message, actionTitle: title, target: self, action: #selector(checkForUpdatesButtonPressed), animated: true)
  }

  func checkForUpdatesButtonPressed() {
    if let url = URL(string: "https://cocoapods.org/app") {
      NSWorkspace.shared().open(url)
    }
  }
  
  var linePrefix: String? {
    get {
      guard let line = selectedLines(editor.textView).first else { return nil }
      
      let startingSelection = editor.textView.selectedRange()
      let range = selectedLinesRange(editor.textView)
      let cursorPosition = startingSelection.location - range.location
      return (line as NSString).substring(to: cursorPosition)
    }
  }

  var cursorIsInsidePodQuote: Bool {
    guard let stringBefore = linePrefix else { return false }
    if stringBefore.contains("pod") == false { return false }
    return stringBefore.components(separatedBy: "'").count == 2 ||
           stringBefore.components(separatedBy: "\"").count == 2
  }
  
  var cursorIsInsidePodVersionQuote: Bool {
    guard let stringBefore = linePrefix else { return false }
    
    if stringBefore.contains("pod") == false { return false }
    return stringBefore.components(separatedBy: "'").count == 4 ||
      stringBefore.components(separatedBy: "\"").count == 4
  }
  
  func selectedLinePodName() -> String? {
    guard let line = selectedLines(editor.textView).first else { return nil }
    
    let components = line.components(separatedBy: "'")
    if components.count >= 2 {
      return components[1]
    } else {
      return nil
    }
  }
  
  func updateAutocompletionsIfNeeded() {
    if let podName = selectedLinePodName() {
      fetchPodVersions(podName) { self.selectedLinePodVersions = $0 }
    } else {
      selectedLinePodVersions = []
    }
  }
  
  func fetchPodVersions(_ podName: String, completion: @escaping ([String]) -> ()) {
    let appDelegate = NSApp.delegate as? CPAppDelegate
    
    if let reflectionServiceProxy = appDelegate?.reflectionService.remoteObjectProxy as? CPReflectionServiceProtocol {
      reflectionServiceProxy.versions(forPodNamed: podName) { (vs, error) in
        guard let vs = vs else { dump(error); return }
        completion(vs.map { "~> \($0)" })
      }
    }
  }

  var cursorInComment: Bool {
    guard let line = selectedLines(editor.textView).first else { return false }
    let trimmed = line.trimmingCharacters(in: CharacterSet.whitespaces)

    return (trimmed as NSString).substring(to: 1) == "#"
  }

  func completions() -> [Any]! {
    switch (cursorInComment, cursorIsInsidePodQuote, cursorIsInsidePodVersionQuote) {
    case (true, _, _):
      return []
    case (_, true, _):
      return allPodNames as [Any]
    case (_, _, true):
      return selectedLinePodVersions as [Any]
    default:
      return autoCompletions as [Any]
    }
  }

  func textDidChange(_ notification: Notification) {
    guard
      let textView = notification.object as? NSTextView,
      let podfileVC = podfileViewController else { return }

    podfileVC.userProject.contents = textView.string ?? ""

    // Passing the message on to the syntax checker
    syntaxChecker.textDidChange(notification)
  }
  
  func textViewDidChangeSelection(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView, textView == editor.textView else { return }
    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
      self.updateAutocompletionsIfNeeded()
    }
  }

  @IBAction func commentSelection(_ sender: NSMenuItem) {
    let selection = selectedLines(editor.textView)
    let change = commentsInSelection(selection) ? removeCommentsFromLines : addCommentsInLines
    let range = applyTextChange(change, toSelection: selection)
    editor.textView.setSelectedRange(NSMakeRange(range.location + range.length, 0))
  }

  @IBAction func indentSelection(_ sender: NSMenuItem) {
    let range = applyTextChange(indentedSelection, toSelection: selectedLines(editor.textView))
    editor.textView.setSelectedRange(range)
  }

  @IBAction func outdentSelection(_ sender: NSMenuItem) {
    let range = applyTextChange(outdentedSelection, toSelection: selectedLines(editor.textView))
    editor.textView.setSelectedRange(range)
  }
  
  @IBAction func increaseFontSize(_ sender: NSMenuItem) {
    let settings = CPFontAndColourGateKeeper()
    settings.increaseDefaultFontSize()
    editor.textFont = settings.defaultFont!
  }
  
  @IBAction func decreaseFontSize(_ sender: NSMenuItem) {
    let settings = CPFontAndColourGateKeeper()
    settings.decreaseDefaultFontSize()
    editor.textFont = settings.defaultFont!
  }

  /// Apply a text transformation to a selection
  ///
  /// The transformation is provided as a closure. Returns an NSRange with the new selection, maintaining selected
  /// the string selected by the user.
  /// - parameter change: the closure that accepts `[String]` and returns `[String]`
  /// - parameter selection: an array of Strings representing the lines of the selection
  /// - returns: NSRange

  func applyTextChange(_ change: (([String]) -> [String]), toSelection selection: [String]) -> NSRange {
    let startingSelection = editor.textView.selectedRange()
    let linesSelection = selectedLinesRange(editor.textView)
    let processed = change(selection)
    let newText = "\(processed.joined(separator: "\n"))\n"

    editor.textView.setSelectedRange(linesSelection)
    editor.textView.insertText(newText)

    // Restore the user's selection by calculating how the text moved
    let charDifference = linesSelection.length - newText.characters.count

    // Figure out how the first line (the starting location of the selection) moved
    let firstLineChange = ((processed.first?.characters.count ?? 0) - (selection.first?.characters.count ?? 0))

    // Return the new selection. Comparing the starting point with the absolute location of the first line 
    // prevents the cursor from skipping back to the line above
    return NSMakeRange(max(linesSelection.location, startingSelection.location + firstLineChange),
      startingSelection.length - charDifference - firstLineChange)
  }

}

/// Implements methods to indent the Podfile

typealias Indentation = CPPodfileEditorViewController
extension Indentation {

  /// Indents the selected text
  ///
  /// Adds two white spaces at the start of each line
  /// - parameter lines: an array of strings representing the user's selection
  /// - returns: [String]

  func indentedSelection(_ selection: [String]) -> [String] {
    return selection.map { line in
      return line.replacingCharacters(in: line.startIndex ..< line.startIndex, with: indentationSyntax)
    }
  }

  /// Outdents the current selection
  ///
  /// Removes either a single tab or a single string formed by one or two white spaces from the start of the lines
  /// - parameter lines: an array of strings representing the user's selection
  /// - returns: [String]

  func outdentedSelection(_ selection: [String]) -> [String] {
    let indent = try! NSRegularExpression(pattern: "^\t|^\\s{1,2}", options: .caseInsensitive)
    return selection.map { line in
      let firstMatch = indent.rangeOfFirstMatch(in: line, options: .anchored, range: NSMakeRange(0, line.characters.count))
      return firstMatch.location != NSNotFound ? (line as NSString).replacingCharacters(in: firstMatch, with: "") : line
    }
  }

}

/// Implements methods to toggle comments in the Podfile

typealias Commenting = CPPodfileEditorViewController
extension Commenting {

  /// Checks wether the selection consists of solely comments
  /// - parameter selection: an array of strings representing the user's selection
  /// - returns: Bool

  func commentsInSelection(_ selection: [String]) -> Bool {
    let regex = try! NSRegularExpression(pattern: "\\s*#\\s*", options: .caseInsensitive)

    return selection.reduce(true) { (all, line) -> Bool in
      return regex.matches(in: line, options: .anchored, range: NSMakeRange(0, line.characters.count)).count > 0 && all
    }
  }

  /// Removes the comment syntax from the selection. 
  ///
  /// Removes '# ' and '#' occurences from the start of the lines
  /// - parameter lines: an array of strings representing the user's selection
  /// - returns: [String]

  func removeCommentsFromLines(_ lines: [String]) -> [String] {
    let comment = try! NSRegularExpression(pattern: "#\\s?", options: .caseInsensitive)
    return lines.map { line in
      let firstMatch = comment.rangeOfFirstMatch(in: line, options: .anchored, range: NSMakeRange(0, line.characters.count))
      return (line as NSString).replacingCharacters(in: firstMatch, with: "")
    }
  }

  /// Adds the comment syntax to the selected text
  ///
  /// Adds '# ' at the start of each line
  /// - parameter lines: an array of strings representing the user's selection
  /// - returns: [String]

  func addCommentsInLines(_ lines: [String]) -> [String] {
    return lines.map { line in
      return line.replacingCharacters(in: line.startIndex ..< line.startIndex, with: commentSyntax)
    }
  }

}

/// Implements methods to retrieve the selected lines of text from a NSTextView

typealias EditorLineSelection = CPPodfileEditorViewController
extension EditorLineSelection {

  /// Returns the selected lines of text as an array of strings
  ///
  /// - parameter textView: the `NSTextView` containing the selection
  /// - returns: [String]

  func selectedLines(_ textView: NSTextView) -> [String] {
    guard let selection = selectedLinesText(textView), selection.characters.count > 0 else { return [] }

    // The substring is required to filter out the empty last line returned otherwise
    return selection.substring(to: selection.characters.index(before: selection.endIndex)).components(separatedBy: "\n")
  }

  /// Returns the text for the selected lines. It includes partially selected lines of text.
  ///
  /// - parameter textView: the `NSTextView` containing the selection
  /// - returns: String?

  func selectedLinesText(_ textView: NSTextView) -> String? {
    guard let text = textView.string else { return .none }

    return (text as NSString).substring(with: selectedLinesRange(textView))
  }

  /// Returns the selected text's range
  ///
  /// - parameter textView: the `NSTextView` containing the selection
  /// - returns: NSRange

  func selectedLinesRange(_ textView: NSTextView) -> NSRange {
    guard let text = textView.string else { return NSMakeRange(0, 0) }

    return (text as NSString).lineRange(for: editor.textView.selectedRange())
  }

}

// MARK: - CPUserProjectDelegate
extension CPPodfileEditorViewController: CPUserProjectDelegate {
  
  func contentDidChangeinUserProject(_ userProject: CPUserProject) {
    let contentChanged = editor.string as String != userProject.contents
    let appIsActive = NSApplication.shared().isActive

    if contentChanged && !appIsActive {
      let selection = editor.textView.selectedRange()
      let scroll = editor.scrollView.visibleRect

      editor.string = userProject.contents as NSString

      editor.textView.selectedRange = selection
      editor.scrollView.scroll(scroll.origin)
    }
    
    // Passing the message on to the syntax checker
    syntaxChecker.textDidChange(Notification(name: Notification.Name(rawValue: ""), object: nil))
  }
}
