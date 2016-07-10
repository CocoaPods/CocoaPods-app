#import "CPCLIToolInstallationController.h"

#import <libgen.h>
#import <Cocoa/Cocoa.h>
#import <SecurityFoundation/SFAuthorization.h>

NSString * const kCPDoNotRequestCLIToolInstallationAgainKey = @"CPDoNotRequestCLIToolInstallationAgain";
NSString * const kCPCLIToolInstalledToDestinationsKey = @"CPCLIToolInstalledToDestinations";

@interface CPCLIToolInstallationController ()
/// The current destination to install the binstub to.
@property (strong) NSURL *destinationURL;
/// A list of existing URL->BookmarkData mappings.
@property (strong) NSDictionary *previouslyInstalledToDestinations;
/// An error message if something fails
@property (strong) NSString *errorMessage;
@end

@implementation CPCLIToolInstallationController

+ (instancetype)controllerWithSuggestedDestinationURL:(NSURL *)suggestedDestinationURL;
{
  return [[self alloc] initWithSuggestedDestinationURL:suggestedDestinationURL];
}

- (instancetype)initWithSuggestedDestinationURL:(NSURL *)suggestedDestinationURL;
{
  if ((self = [super init])) {
    _destinationURL = suggestedDestinationURL;
  }
  return self;
}

- (BOOL)shouldInstallBinstubIfNecessary;
{
  if ([self hasInstalledBinstubBefore]) {
    NSLog(@"Already installed binstub.");
    return NO;
  }

  if ([[NSUserDefaults standardUserDefaults] boolForKey:kCPDoNotRequestCLIToolInstallationAgainKey]) {
    NSLog(@"Asking the user to install the binstub again is prohibited.");
    return NO;
  }

  return ![self binstubAlreadyExists];
}


- (BOOL)installBinstubIfNecessary;
{
  if ([self shouldInstallBinstubIfNecessary]) {
      return [self installBinstub];
  }
  return NO;
}

- (BOOL)installBinstub;
{
  BOOL installed = NO;
  [self verifyExistingInstallDestinations];

  if ([self promptIfOverwriting]) {
    NSLog(@"Try to install binstub to `%@`.", self.destinationURL.path);

    installed = [self installBinstubAccordingToPrivileges];
    if (installed) {
      NSLog(@"Successfully wrote binstub to destination.");
      [self saveInstallationDestination];
    }
  }

  return installed;
}

#pragma mark - Uninstallation

- (BOOL)hasInstalledBinstubBefore
{
  [self verifyExistingInstallDestinations];
  
  return self.previouslyInstalledToDestinations.count > 0;
}

- (BOOL)removeBinstub
{
  [self verifyExistingInstallDestinations];
  
  if (![self hasInstalledBinstubBefore]) {
    NSLog(@"Tried to remove binstub, but it was never installed using the app before.");
    return NO;
  }
  
  if (![self promptIfUserReallyWantsToUninstall]) {
    NSLog(@"User canceled removing binstub.");
    return NO;
  }
  
  // go ahead and delete it
  NSLog(@"Now removing binstub ...");
  
  NSDictionary *remainingURLs = [self removeBinstubAccordingToPrivileges];
  
  [self saveBookmarksWithURLs:remainingURLs];
  
  // success only when we have successfully removed all urls from file system
  NSLog(@"Finished removing binstub: %@", self.previouslyInstalledToDestinations.count == 0 ? @"success" : @"failed");
  return self.previouslyInstalledToDestinations.count == 0;
}

#pragma mark - Installation destination bookmarks

static NSData *
CPBookmarkDataForURL(NSURL *URL) {
  NSError *error = nil;
  NSData *data = [URL bookmarkDataWithOptions:0
               includingResourceValuesForKeys:nil
                                relativeToURL:nil
                                        error:&error];
  if (error) {
    NSLog(@"Unable to create bookmark data for binstub install destination (%@)", error);
    return nil;
  }
  return data;
}

// Loads the existing bookmarks of destinations that the binstub was previously installed to. If the
// bookmark data is stale or unable to load at all, the list is updated accordingly.
//
// This should be called *before* performing a new installation, otherwise the following problem can
// occur: http://stackoverflow.com/questions/16614858
//
- (void)verifyExistingInstallDestinations;
{
  // Currently not designed to be thread-safe.
  if (self.previouslyInstalledToDestinations != nil) {
    return;
  }

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *bookmarks = [defaults arrayForKey:kCPCLIToolInstalledToDestinationsKey];
  if (bookmarks == nil) {
    self.previouslyInstalledToDestinations = [NSDictionary dictionary];
  } else {
    NSLog(@"Verifying existing destinations.");
    NSUInteger bookmarkCount = bookmarks.count;
    NSMutableDictionary *URLs = [NSMutableDictionary dictionaryWithCapacity:bookmarkCount];
    for (NSUInteger i = 0; i < bookmarkCount; i++) {
      NSData *bookmark = [bookmarks objectAtIndex:i];
      BOOL stale = NO;
      NSError *error = nil;
      NSURL *URL = [NSURL URLByResolvingBookmarkData:bookmark
                                             options:NSURLBookmarkResolutionWithoutUI |
                                                     NSURLBookmarkResolutionWithoutMounting
                                       relativeToURL:nil
                                 bookmarkDataIsStale:&stale
                                               error:&error];
      if (error) {
        NSLog(@"Unable to resolve bookmark, thus skipping (%@)", error);
      } else {
        if (stale) {
          NSLog(@"Updating stale bookmark now located at %@", URL);
          NSData *updatedBookmark = CPBookmarkDataForURL(URL);
          if (updatedBookmark) {
            bookmark = updatedBookmark;
          } else {
            NSLog(@"Maintain stale bookmark, because creating a new bookmark failed.");
          }
        }
#ifdef DEBUG
        else {
          NSLog(@"Verified still existing bookmark at %@", URL);
        }
#endif
        URLs[URL] = bookmark;
      }
    }
    [self saveBookmarksWithURLs:URLs];
  }
}

// Adds the current `destinationURL` to the saved bookmarks for future updating, if the binstub ever
// needs updating.
//
- (void)saveInstallationDestination;
{
  NSData *bookmark = CPBookmarkDataForURL(self.destinationURL);
  if (bookmark) {
    NSMutableDictionary *URLs = [self.previouslyInstalledToDestinations mutableCopy];
    // Update any previous bookmark data pointing to the same destination.
    URLs[self.destinationURL] = bookmark;
    [self saveBookmarksWithURLs:URLs];
  }
}

// Prompts to warn someone that they're going to have a binstub replaced
// returns whether the install action should continue

- (BOOL)promptIfOverwriting
{
  if ([self binstubAlreadyExists] == NO) {
    return YES;
  }

  /// Don't prompt if it's going to put the same binary in the place
  if ([self binstubAlreadyIsTheLatestVersion] == NO) {
    return YES;
  }

  BOOL isRubyGemsVersion = [self currentBinStubComesFromRubygems];

  NSAlert *alert = [NSAlert new];
  alert.alertStyle = NSCriticalAlertStyle;
  NSString *formatString = NSLocalizedString(@"INSTALL_CLI_WARNING_MESSAGE_TEXT", nil);
  alert.messageText = [NSString stringWithFormat:formatString, self.destinationURL.path];

  NSString *information = isRubyGemsVersion ? @"INSTALL_CLI_FROM_GEM_INFORMATIVE_TEXT" : @"INSTALL_CLI_WARNING_INFORMATIVE_TEXT";
  alert.informativeText = NSLocalizedString(information, nil);

  [alert addButtonWithTitle:NSLocalizedString(@"INSTALL_CLI_WARNING_OVERWRITE", nil)];
  [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];

  return [alert runModal] == NSAlertFirstButtonReturn;
}

- (BOOL)promptIfUserReallyWantsToUninstall
{
  NSAlert *alert = [NSAlert new];
  alert.alertStyle = NSCriticalAlertStyle;
  alert.messageText = NSLocalizedString(@"UNINSTALL_CLI_WARNING_MESSAGE_TEXT", nil);
  
  [alert addButtonWithTitle:NSLocalizedString(@"UNINSTALL_CLI_REMOVE", nil)];
  [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
  
  return [alert runModal] == NSAlertFirstButtonReturn;
}

#pragma mark - Utility

- (void)saveBookmarksWithURLs:(NSDictionary *)URLs
{
  self.previouslyInstalledToDestinations = [URLs copy];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *bookmarks = [URLs allValues];
  if (bookmarks.count == 0) {
    [defaults removeObjectForKey:kCPCLIToolInstalledToDestinationsKey];
  } else {
    [defaults setObject:bookmarks
                 forKey:kCPCLIToolInstalledToDestinationsKey];
  }
}

- (NSURL *)binstubSourceURL;
{
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  return [NSURL fileURLWithPathComponents:@[ bundlePath, @"Contents", @"Helpers", @"pod" ]];
}

- (BOOL)currentBinStubComesFromRubygems
{
  NSError *error = nil;
  NSString *contents = [NSString stringWithContentsOfURL:self.destinationURL encoding:NSUTF16StringEncoding error:&error];
  if (error) {
    NSLog(@"Error looking at BinStub: %@", error);
    return NO;
  }

  NSString *message = @"generated by RubyGems.";
  return [contents containsString:message];
}

- (BOOL)binstubAlreadyExists;
{
  return access([self.destinationURL.path UTF8String], F_OK) == 0;
}

- (BOOL)binstubAlreadyIsTheLatestVersion;
{
  return [[NSFileManager defaultManager] contentsEqualAtPath:self.destinationURL.path andPath:self.binstubSourceURL.path];
}

- (BOOL)hasWriteAccessToBinstub;
{
  return [self hasWriteAccessToBinstubWithURL:self.destinationURL];
}

- (BOOL)hasWriteAccessToBinstubWithURL:(NSURL *)url;
{
  NSURL *destinationDirURL = [url URLByDeletingLastPathComponent];
  return access([destinationDirURL.path UTF8String], W_OK) == 0;
}

- (BOOL)runModalDestinationChangeSavePanel;
{
  NSSavePanel *savePanel = [NSSavePanel savePanel];
  savePanel.canCreateDirectories = YES;
  savePanel.showsHiddenFiles = YES;
  savePanel.directoryURL = [self.destinationURL URLByDeletingLastPathComponent];
  savePanel.nameFieldStringValue = self.destinationURL.lastPathComponent;
  if ([savePanel runModal] == NSFileHandlingPanelCancelButton) {
    return NO;
  }

  self.destinationURL = savePanel.URL;
  return YES;
}

#pragma mark - Binstub installation

// Performs the installation flow according to the required privileges for `destinationURL`.
//
// Returns whether or not it succeeded.
//
- (BOOL)installBinstubAccordingToPrivileges;
{
  self.errorMessage = nil;
  if ([self hasWriteAccessToBinstub]) {
    return [self installBinstubToAccessibleDestination];
  } else {
    return [self installBinstubToPrivilegedDestination];
  }
}

// This simply performs a copy operation of the binstub to the destination without asking the user
// for authorization.
//
// Returns whether or not it succeeded.
//
- (BOOL)installBinstubToAccessibleDestination;
{
  NSError *error = nil;
  NSURL *sourceURL = self.binstubSourceURL;
  NSFileManager *fileManager = [NSFileManager defaultManager];

  if ([fileManager fileExistsAtPath:self.destinationURL.path]) {
    [fileManager removeItemAtURL:self.destinationURL error:&error];
  }

  BOOL succeeded = [fileManager copyItemAtURL:sourceURL toURL:self.destinationURL error:&error];
  if (error) {
    NSLog(@"Failed to copy source `%@` (%@)", sourceURL.path, error);
    self.errorMessage = @"Failed to move pod command to the new folder";
    succeeded = NO;
  }
  return succeeded;
}

// Tries to install the binstub to `destinationURL` by asking the user for authorization to write to
// the destination first.
//
// Returns whether or not it succeeded.
//
- (BOOL)installBinstubToPrivilegedDestination;
{
  const char *destination_path = [self.destinationURL.path UTF8String];

  // Configure requested authorization.
  char name[1024];
  sprintf(name, "sys.openfile.readwritecreate.%s", destination_path);
  AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed |
                             kAuthorizationFlagExtendRights |
                             kAuthorizationFlagPreAuthorize;

  // Request the user for authorization.
  NSError *error = nil;
  SFAuthorization *authorization = [SFAuthorization authorization];
  if (![authorization obtainWithRight:name flags:flags error:&error]) {
    NSLog(@"Did not authorize.");
    self.errorMessage = @"Did not get authorization to save pod command";
    return NO;
  }

  // Serialize the AuthorizationRef so it can be passed to the `authopen` tool.
  AuthorizationRef authorizationRef = [authorization authorizationRef];
  AuthorizationExternalForm serializedRef;
  OSStatus serialized = AuthorizationMakeExternalForm(authorizationRef, &serializedRef);
  if (serialized != errAuthorizationSuccess) {
    NSLog(@"Failed to serialize AuthorizationRef (%d)", serialized);
    self.errorMessage = @"Could not use given authorization to save pod command";
    return NO;
  }

  // Create a pipe through the `authopen` tool that allows file creation and
  // writing to the destination and also marks the file as being executable.
  char command[1024];
  sprintf(command, "/usr/libexec/authopen -extauth -c -m 0755 -w %s", destination_path);
  errno = 0;
  BOOL succeeded = NO;
  FILE *destination_pipe = popen(command, "w");
  if (destination_pipe == NULL) {
    NSLog(@"Failed to open pipe to `authopen` (%d - %s)", errno, strerror(errno));
  } else {
    // First send the pre-authorized and serialized AuthorizationRef so that the
    // `authopen` tool does not need to request authorization from the user,
    // which would lead to the user seeing an authorization dialog from
    // `authopen` instead of this app.
    fwrite(&serializedRef, sizeof(serializedRef), 1, destination_pipe);
    fflush(destination_pipe);
    // Now write the actual file data.
    NSURL *sourceURL = self.binstubSourceURL;
    FILE *source_file = fopen([sourceURL.path UTF8String], "r");
    if (source_file == NULL) {
      NSLog(@"Failed to open source `%@` (%d - %s)", sourceURL.path, errno, strerror(errno));
      self.errorMessage = @"Could open a file to save pod command";
    } else {
      int c;
      while ((c = fgetc(source_file)) != EOF) {
        fwrite(&c, 1, 1, destination_pipe);
      }
      fclose(source_file);
      succeeded = YES;
    }
    pclose(destination_pipe);
  }
  return succeeded;
}

#pragma mark - Binstub uninstallation

/// Loops through all installed destinations and tries to remove them.
///
/// @return Dictionary of remaining bookmarks which couldn't be removed. Empty dict means everything was succuessfully removed.
///
- (NSDictionary *)removeBinstubAccordingToPrivileges
{
  self.errorMessage = nil;
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSMutableArray *privilegedURLs = [NSMutableArray array];
  NSMutableDictionary *URLs = [self.previouslyInstalledToDestinations mutableCopy];
  for (NSURL *url in self.previouslyInstalledToDestinations) {
    
    if (![fileManager fileExistsAtPath:url.path]) {
      // remove url from our list
      [URLs removeObjectForKey:url];
      continue;
    }
    
    NSLog(@"Removing binstub: %@", url.path);
    
    BOOL removed = NO;
    if ([self hasWriteAccessToBinstubWithURL:url]) {
      removed = [self removeBinstubFromAccessibleDestinationWithURL:url];
    } else {
      removed = NO; // will be done few lines below
      [privilegedURLs addObject:url];
    }
    
    if (removed) {
      [URLs removeObjectForKey:url];
    }
  }
  
  // now remove privileged urls all at once
  if (privilegedURLs.count > 0) {
    BOOL removed = [self removeBinstubFromPrivilegedDestinationWithURLs:privilegedURLs];
    if (removed) {
      [URLs removeObjectsForKeys:privilegedURLs];
    }
  }
  
  return [URLs copy];
}

- (BOOL)removeBinstubFromAccessibleDestinationWithURL:(NSURL *)url
{
  NSError *error = nil;
  BOOL success = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
  
  if (error) {
    NSLog(@"Failed to remove binstub: %@", error);
    self.errorMessage = @"Failed to remove pod command";
    success = NO;
  }
  
  return success;
}

// Possible Solutions how to gain privileged access to remove files:
// 1. `AuthorizationExecuteWithPrivileges` but its deprecated since OS X 10.7: [1] and [2]
// 2. `ServiceManagement.framework`'s `SMJobBless()`: [3] and [4]
// 3. AppleScript: [5] and [6]
//
// Disadvantage of solution #3 is that authorization dialog will pop up for each
//
// References:
// [1] http://www.michaelvobrien.com/blog/2009/07/authorizationexecutewithprivileges-a-simple-example/
// [2] https://developer.apple.com/library/mac/documentation/Security/Conceptual/authorization_concepts/03authtasks/authtasks.html
// [3] http://stackoverflow.com/a/6842129
// [4] https://developer.apple.com/library/mac/samplecode/EvenBetterAuthorizationSample/Listings/Read_Me_About_EvenBetterAuthorizationSample_txt.html#//apple_ref/doc/uid/DTS40013768-Read_Me_About_EvenBetterAuthorizationSample_txt-DontLinkElementID_17
// [5] http://stackoverflow.com/a/8865284
// [6] http://stackoverflow.com/a/15248621
- (BOOL)removeBinstubFromPrivilegedDestinationWithURLs:(NSArray<NSURL *> *)urls {
  if (urls.count == 0) {
    return NO;
  }
  
  NSArray<NSString *> *paths = [urls valueForKey:@"path"];  // NSURL.path
  NSString *pathsArgumentString = [NSString stringWithFormat:@"'%@'", [paths componentsJoinedByString:@"' '"]]; // [asdf, wasd] --> 'asdf' 'wasd'
  
  NSString *output = nil;
  NSString *processErrorDescription = nil;
  
  // Command: `'/bin/rm' -f '/usr/local/bin/pod' '/usr/local/bin/path with space/someOtherBinary'`
  BOOL success = [self runProcessAsAdministrator:@"/bin/rm"
                                   withArguments:@[@"-f", pathsArgumentString]
                                          output:&output
                                errorDescription:&processErrorDescription];
  
  // Process failed to run
  if (!success) {
    NSLog(@"Failed to remove Binstub from privileged destination: %@", processErrorDescription);
  }
  return success;
}

// Using AppleScript
// Source: [6] (StackOverflow)
- (BOOL)runProcessAsAdministrator:(NSString *)scriptPath
                    withArguments:(NSArray *)arguments
                           output:(NSString **)output
                 errorDescription:(NSString **)errorDescription {
  
  NSString *allArgs = [arguments componentsJoinedByString:@" "];
  NSString *fullScript = [NSString stringWithFormat:@"'%@' %@", scriptPath, allArgs];
  
  NSDictionary *errorInfo = [NSDictionary new];
  NSString *script = [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
  
  NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
  NSAppleEventDescriptor *eventResult = [appleScript executeAndReturnError:&errorInfo];
  
  if (eventResult) {
    // Set output to the AppleScript's output
    *output = [eventResult stringValue];
    
    return YES;
  }
  
  // Check errorInfo & describe common errors
  *errorDescription = nil;
  if ([errorInfo valueForKey:NSAppleScriptErrorNumber]) {
    NSNumber *errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
    if ([errorNumber intValue] == -128) {
      *errorDescription = @"The administrator password is required to do this.";
    }
  }
  
  // Set error message from provided message
  if (*errorDescription == nil) {
    if ([errorInfo valueForKey:NSAppleScriptErrorMessage]) {
      *errorDescription = (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
    }
  }
  
  return NO;
}

@end
