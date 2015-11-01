#import <Cocoa/Cocoa.h>
#import "CPExternalLinksHelper.h"

@implementation CPExternalLinksHelper

- (IBAction)whatsNew:(id)sender;
{
  [self open:@"https://github.com/CocoaPods/CocoaPods-app/releases"];
}

- (IBAction)openGuides:(id)sender;
{
  [self open:@"http://guides.cocoapods.org/"];
}

- (IBAction)openPodspecReference:(id)sender;
{
  [self open:@"http://guides.cocoapods.org/syntax/podspec.html"];
}

- (IBAction)openPodfileReference:(id)sender;
{
  [self  open:@"http://guides.cocoapods.org/syntax/podfile.html"];
}

- (IBAction)openSearch:(id)sender;
{
  [self  open:@"http://cocoapods.org/"];
}


- (void)open:(NSString *)address
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:address]];
}

@end
