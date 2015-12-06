import XCTest
import Quick
import Nimble
import Cocoa

class CocoaPodsTests: NSObject {}

extension NSStoryboard {

  class func podfile() -> NSStoryboard {
    return NSStoryboard(name: "Podfile", bundle: NSBundle(forClass: CocoaPodsTests.self))
  }
}