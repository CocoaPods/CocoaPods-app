#import <Cocoa/Cocoa.h>

@interface CPHomeWindowController : NSWindowController <NSDraggingDestination>

/// Forces the installation of the binstub
- (IBAction)installBinstub:(id)sender;

@end
