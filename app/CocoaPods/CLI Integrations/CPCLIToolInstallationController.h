#import <Foundation/Foundation.h>

extern NSString * const kCPDoNotRequestCLIToolInstallationAgainKey;
extern NSString * const kCPCLIToolInstalledToDestinationsKey;

@interface CPCLIToolInstallationController : NSObject
@property (readonly) NSURL *destinationURL;
@property (readonly) NSString *errorMessage;

+ (instancetype)controllerWithSuggestedDestinationURL:(NSURL *)suggestedDestinationURL;

/// Checks if binstub is not installed yet and is not configured to not request the
/// user for installation again (`kCPRequestCLIToolInstallationAgainKey`).
///
/// Returns whether or not installation should be performed.

- (BOOL)shouldInstallBinstubIfNecessary;

/// Only performs the installation if it's not installed yet and is not configured to not request the
/// user for installation again (`kCPRequestCLIToolInstallationAgainKey`).
///
/// Returns whether or not installation has been performed.
///
- (BOOL)installBinstubIfNecessary;

/// Always tries to perform the installation, unless the user cancels an overwrite.
///
/// Returns whether or not installation has been performed.
///
- (BOOL)installBinstub;


/// Allows the user to choose a different destination than the suggested destination.
///
/// Updates the `destinationURL` if the user chooses a new one.
///
/// Returns whether or not a destination was chosen or if the user cancelled.
///
- (BOOL)runModalDestinationChangeSavePanel;

/// Checks if a binstub already exists, note: this could return `YES`
/// from a `gem install cocoapods`, and so may not actually be a "binstub"

- (BOOL)binstubAlreadyExists;


@end
