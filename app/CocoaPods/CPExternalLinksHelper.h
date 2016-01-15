#import <Foundation/Foundation.h>

@interface CPExternalLinksHelper : NSObject

/// Opens the release section on GitHub
- (IBAction)whatsNew:(id)sender;

/// Opens the CocoaPods Guides
- (IBAction)openGuides:(id)sender;

/// Opens the Podspec reference
- (IBAction)openPodspecReference:(id)sender;

/// Opens the Podfile reference
- (IBAction)openPodfileReference:(id)sender;

/// Opens the search page
- (IBAction)openSearch:(id)sender;

/// Opens a Pod page
- (void)openPodWithName:(NSString *)name;

@end
