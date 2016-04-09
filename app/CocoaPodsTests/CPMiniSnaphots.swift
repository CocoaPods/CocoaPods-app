import Cocoa

// Provides a vastly simplified version of FBSnapshots + Nimble+Snapshots
// for the Mac.

enum SnapshotError: ErrorType {
  case CouldNotGenerateNewSnapshot
  case NoReferenceSnapshotFound
  case SnapshotsDidNotMatch
}

/// Verify a snapshot is what you expect it to be

func verifySnapshot(name: String, view: NSView, file: String = __FILE__) throws {
  guard let data = dataForView(view) else { throw SnapshotError.CouldNotGenerateNewSnapshot }
  let referencePath = pathForName(name, file: file)

  guard let referenceData = NSData(contentsOfFile: referencePath) else { throw SnapshotError.NoReferenceSnapshotFound }
  if data != referenceData { throw SnapshotError.SnapshotsDidNotMatch }
}

/// Create a reference snapshot

func recordSnapshot(name: String, view: NSView, file: String = __FILE__) -> Bool {
  do {
    guard let data = dataForView(view) else { return false }
    try data.writeToFile(pathForName(name, file: file), options: [.DataWritingAtomic])

  } catch {
    return false
  }
  
  return true
}

/// Grabs the NSData representing a view

private func dataForView(view: NSView) -> NSData? {
  guard let rep = view.bitmapImageRepForCachingDisplayInRect(view.bounds) else { return nil }
  view.cacheDisplayInRect(view.bounds, toBitmapImageRep: rep)
  guard let data = rep.representationUsingType(.NSPNGFileType, properties: ["":""]) else { return nil }
  return data
}

/// Gets the full path for a name in a test file

private func pathForName(name: String, file: String) -> String {
  let folder = referencePathForTests(file)
  return folder + name + ".png"
}

// Note that these must be lower case.
private var testFolderSuffixes = ["tests", "specs"]

/// Gets the path for a test file's folder

private func referencePathForTests(sourceFileName: String) -> String {

  // Search the test file's path to find the first folder with a test suffix,
  // then append "/ReferenceImages" and use that.

  // Grab the file's path
  let pathComponents: NSArray = (sourceFileName as NSString).pathComponents

  // Find the directory in the path that ends with a test suffix.
  let testPath = pathComponents.filter { component -> Bool in
    return testFolderSuffixes.filter { component.lowercaseString.hasSuffix($0) }.count > 0
    }.first

  guard let testDirectory = testPath else {
    fatalError("Could not infer reference image folder.")
  }

  // Recombine the path components and append our own image directory.
  let currentIndex = pathComponents.indexOfObject(testDirectory) + 1
  let folderPathComponents: NSArray = pathComponents.subarrayWithRange(NSMakeRange(0, currentIndex))
  let folderPath = NSString.pathWithComponents(folderPathComponents as! [String])

  return folderPath + "/ReferenceImages"
}
