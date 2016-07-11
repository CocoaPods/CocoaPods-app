#import <Cocoa/Cocoa.h>

@interface CPHomeWindowController : NSWindowController <NSDraggingDestination>

/// Checks if binstab is already installed
- (BOOL)isBinstubAlreadyInstalled;

/// Forces the installation of the binstub
- (IBAction)installBinstub:(id)sender;

/// Removes alraedy installed binstub
- (IBAction)removeBinstub:(id)sender;

@end
