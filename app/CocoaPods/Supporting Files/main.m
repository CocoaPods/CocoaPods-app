#import <Cocoa/Cocoa.h>
#import "CocoaPods-Swift.h"

int CPApplicationMain(int argc, const char *argv[]) {
  [NSApplication sharedApplication];

  id<NSApplicationDelegate> testDelegate = nil;
  if (NSClassFromString(@"XCTestCase") != Nil) {
    NSString *testBundlePath = [[NSProcessInfo processInfo] environment][@"XCInjectBundle"];
    NSCParameterAssert(testBundlePath);
    NSCParameterAssert([[NSBundle bundleWithPath:testBundlePath] load]);
    testDelegate = [NSClassFromString(@"CPTestHelper") new];
    NSApp.delegate = testDelegate;
  }

  [NSBundle loadNibNamed:@"MainMenu" owner:NSApp];

  [NSApp run];
  return 0;
}

int main(int argc, const char * argv[]) {
  return CPApplicationMain(argc, argv);
}
