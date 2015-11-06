#import "CPCLIToolInstallationController.h"

#import <libgen.h>
#import <Cocoa/Cocoa.h>
#import <SecurityFoundation/SFAuthorization.h>

NSString * const kCPDoNotRequestCLIToolInstallationAgainKey = @"CPDoNotRequestCLIToolInstallationAgain";
NSString * const kCPCLIToolInstalledToDestinationsKey = @"CPCLIToolInstalledToDestinations";

@interface CPCLIToolInstallationController ()
// The current destination to install the binstub to.
@property (strong) NSURL *destinationURL;
// A list of existing URL->BookmarkData mappings.
@property (strong) NSDictionary *previouslyInstalledToDestinations;
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

- (BOOL)installBinstubIfNecessary;
{
  [self verifyExistingInstallDestinations];

  if (self.previouslyInstalledToDestinations.count > 0) {
    NSLog(@"Already installed binstub.");
    return NO;
  }

  if ([[NSUserDefaults standardUserDefaults] boolForKey:kCPDoNotRequestCLIToolInstallationAgainKey]) {
    NSLog(@"Asking the user to install the binstub again is prohibited.");
    return NO;
  }

  return [self installBinstub];
}

- (BOOL)installBinstub;
{
  BOOL installed = NO;
  if ([self runModalInstallationRequestAlert]) {
    [self verifyExistingInstallDestinations];
    NSLog(@"Try to install binstub to `%@`.", self.destinationURL.path);
    installed = [self installBinstubAccordingToPrivileges];
    if (installed) {
      NSLog(@"Successfully wrote binstub to destination.");
      [self saveInstallationDestination];
    }
  }
  return installed;
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
    NSMutableArray *verifiedBookmarks = [NSMutableArray arrayWithCapacity:bookmarkCount];
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
        [verifiedBookmarks addObject:bookmark];
      }
    }
    self.previouslyInstalledToDestinations = [URLs copy];
    [defaults setObject:[verifiedBookmarks copy]
                 forKey:kCPCLIToolInstalledToDestinationsKey];
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
    NSArray *bookmarks = [URLs allValues];
    [[NSUserDefaults standardUserDefaults] setObject:bookmarks
                                              forKey:kCPCLIToolInstalledToDestinationsKey];
  }
}

#pragma mark - Utility

// Never ask the user to automatically install again.
//
- (void)setDoNotRequestInstallationAgain;
{
  NSLog(@"Not going to automatically request binstub installation anymore.");
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCPDoNotRequestCLIToolInstallationAgainKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURL *)binstubSourceURL;
{
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
  return [NSURL fileURLWithPathComponents:@[ bundlePath, @"Contents", @"Helpers", @"pod" ]];
}

#pragma mark - User interaction (modal windows)

// Returns wether or not the user chose to perform the installation and, in case the user chose a
// different installation destination, the `destinationURL` is updated.
//
// In case the user chose to cancel the operation, this preference is stored and the user will not
// be automatically asked to install again on the next launch.
//
- (BOOL)runModalInstallationRequestAlert;
{
  NSString *destinationFilename = self.destinationURL.lastPathComponent;

  NSAlert *alert = [NSAlert new];
  alert.alertStyle = NSInformationalAlertStyle;
  alert.messageText = NSLocalizedString(@"INSTALL_CLI_MESSAGE_TEXT", nil);
  NSString *formatString = NSLocalizedString(@"INSTALL_CLI_INFORMATIVE_TEXT", nil);
  alert.informativeText = [NSString stringWithFormat:formatString, destinationFilename];
  formatString = NSLocalizedString(@"INSTALL_CLI", nil);
  [alert addButtonWithTitle:[NSString stringWithFormat:formatString, self.destinationURL.path]];
  [alert addButtonWithTitle:NSLocalizedString(@"INSTALL_CLI_ALTERNATE_DESTINATION", nil)];
  [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];

  switch ([alert runModal]) {
    case NSAlertSecondButtonReturn:
      if (![self runModalDestinationSavePanel]) {
        // The user cancelled.
        [self setDoNotRequestInstallationAgain];
        return NO;
      }
      break;
    case NSAlertThirdButtonReturn:
      // The user cancelled.
      [self setDoNotRequestInstallationAgain];
      return NO;
  }

  if (access([self.destinationURL.path UTF8String], F_OK) == 0) {
    alert = [NSAlert new];
    alert.alertStyle = NSCriticalAlertStyle;
    formatString = NSLocalizedString(@"INSTALL_CLI_WARNING_MESSAGE_TEXT", nil);
    alert.messageText = [NSString stringWithFormat:formatString, self.destinationURL.path];
    alert.informativeText = NSLocalizedString(@"INSTALL_CLI_WARNING_INFORMATIVE_TEXT", nil);
    [alert addButtonWithTitle:NSLocalizedString(@"INSTALL_CLI_WARNING_OVERWRITE", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    if ([alert runModal] == NSAlertSecondButtonReturn) {
      // Call recursive until user either saves or cancels from above alert.
      return [self runModalInstallationRequestAlert];
    }
  }

  return YES;
}

// Allows the user to choose a different destination than the suggested destination.
//
// Updates the `destinationURL` if the user chooses a new one.
//
// Returns whether or not a destination was chosen or if the user cancelled.
//
- (BOOL)runModalDestinationSavePanel;
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
  NSURL *destinationDirURL = [self.destinationURL URLByDeletingLastPathComponent];
  if (access([destinationDirURL.path UTF8String], W_OK) == 0) {
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
  BOOL succeeded = [[NSFileManager defaultManager] copyItemAtURL:sourceURL
                                                           toURL:self.destinationURL
                                                           error:&error];
  if (error) {
    NSLog(@"Failed to copy source `%@` (%@)", sourceURL.path, error);
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
    return NO;
  }

  // Serialize the AuthorizationRef so it can be passed to the `authopen` tool.
  AuthorizationRef authorizationRef = [authorization authorizationRef];
  AuthorizationExternalForm serializedRef;
  OSStatus serialized = AuthorizationMakeExternalForm(authorizationRef, &serializedRef);
  if (serialized != errAuthorizationSuccess) {
    NSLog(@"Failed to serialize AuthorizationRef (%d)", serialized);
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

@end
