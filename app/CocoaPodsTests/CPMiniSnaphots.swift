import Cocoa

// Provides a vastly simplified version of FBSnapshots + Nimble+Snapshots
// for the Mac.

enum SnapshotError: Error {
  case couldNotGenerateNewSnapshot
  case noReferenceSnapshotFound
  case snapshotsDidNotMatch
}

/// Verify a snapshot is what you expect it to be

func verifySnapshot(_ name: String, view: NSView, file: String = #file) throws {
  guard let data = dataForView(view) else { throw SnapshotError.couldNotGenerateNewSnapshot }
  let referencePath = pathForName(name, file: file)

  guard let referenceData = try? Data(contentsOf: URL(fileURLWithPath: referencePath)) else { throw SnapshotError.noReferenceSnapshotFound }
  if data != referenceData { throw SnapshotError.snapshotsDidNotMatch }
}

/// Create a reference snapshot

func recordSnapshot(_ name: String, view: NSView, file: String = #file) -> Bool {
  do {
    guard let data = dataForView(view) else { return false }
    try data.write(to: URL(fileURLWithPath: pathForName(name, file: file)), options: [.atomic])

  } catch {
    return false
  }
  
  return true
}

/// Grabs the NSData representing a view

private func dataForView(_ view: NSView) -> Data? {
  guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
  view.cacheDisplay(in: view.bounds, to: rep)
  guard let data = rep.representation(using: .PNG, properties: ["":""]) else { return nil }
  return data
}

/// Gets the full path for a name in a test file

private func pathForName(_ name: String, file: String) -> String {
  let folder = referencePathForTests(file)
  return folder + name + ".png"
}

// Note that these must be lower case.
private var testFolderSuffixes = ["tests", "specs"]

/// Gets the path for a test file's folder

private func referencePathForTests(_ sourceFileName: String) -> String {

  // Search the test file's path to find the first folder with a test suffix,
  // then append "/ReferenceImages" and use that.

  // Grab the file's path
  let pathComponents: NSArray = (sourceFileName as NSString).pathComponents as NSArray

  // Find the directory in the path that ends with a test suffix.
  let testPath = pathComponents.filter { component -> Bool in
    return testFolderSuffixes.filter { (component as AnyObject).lowercased.hasSuffix($0) }.count > 0
    }.first

  guard let testDirectory = testPath else {
    fatalError("Could not infer reference image folder.")
  }

  // Recombine the path components and append our own image directory.
  let currentIndex = pathComponents.index(of: testDirectory) + 1
  let folderPathComponents: NSArray = pathComponents.subarray(with: NSMakeRange(0, currentIndex)) as NSArray
  let folderPath = NSString.path(withComponents: folderPathComponents as! [String])

  return folderPath + "/ReferenceImages"
}
