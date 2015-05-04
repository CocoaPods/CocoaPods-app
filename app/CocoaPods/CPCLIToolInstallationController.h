#import <Foundation/Foundation.h>

extern NSString * const kCPDoNotRequestCLIToolInstallationAgainKey;
extern NSString * const kCPCLIToolInstalledToDestinationsKey;

@interface CPCLIToolInstallationController : NSObject
@property (readonly) NSURL *destinationURL;

+ (instancetype)controllerWithSuggestedDestinationURL:(NSURL *)suggestedDestinationURL;

// Only performs the installation if it's not installed yet and is not configured to not request the
// user for installation again (`kCPRequestCLIToolInstallationAgainKey`).
//
// Returns whether or not installation has been performed.
//
- (BOOL)installBinstubIfNecessary;

// Always tries to perform the installation.
//
// Returns whether or not installation has been performed.
//
- (BOOL)installBinstub;

@end
