#import <Cocoa/Cocoa.h>
#import "CocoaPods-Swift.h"

int main(int argc, const char * argv[]) {

  [NSApplication sharedApplication];

  id<NSApplicationDelegate> testDelegate = nil;
  if (NSClassFromString(@"XCTestCase") != Nil) {
    NSString *testBundlePath = [[NSProcessInfo processInfo] environment][@"XCInjectBundle"];
    NSCParameterAssert(testBundlePath);
    NSCParameterAssert([[NSBundle bundleWithPath:testBundlePath] load]);
    testDelegate = [NSClassFromString(@"CPTestHelper") new];
    NSApp.delegate = testDelegate;
  } else {
    //Loads CPAppDelegate from the .xib.
    [[NSBundle mainBundle] loadNibNamed:@"MainMenu" owner:NSApp topLevelObjects:nil];
  }

  [NSApp run];
  return 0;
}
