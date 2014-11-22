#import "AppDelegate.h"

#import <libgen.h>
#import <SecurityFoundation/SFAuthorization.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
  //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CPHaveAskedUserToInstallTool"];
  //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CPShowVerboseCommandOutput"];
  //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

  [self installBinstubIfNecessary:nil];
}

#pragma mark - Actions

- (IBAction)openGuides:(id)sender;
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guides.cocoapods.org/"]];
}

- (IBAction)openPodspecReference:(id)sender;
{
  NSURL *URL = [NSURL URLWithString:@"http://guides.cocoapods.org/syntax/podspec.html"];
  [[NSWorkspace sharedWorkspace] openURL:URL];
}

- (IBAction)openPodfileReference:(id)sender;
{
  NSURL *URL = [NSURL URLWithString:@"http://guides.cocoapods.org/syntax/podfile.html"];
  [[NSWorkspace sharedWorkspace] openURL:URL];
}

- (IBAction)installBinstubIfNecessary:(id)sender;
{
  // TODO change this to just `pod` for real release and then also update the
  // `sprintf` calls to `snprintf` with hardcoded lengths.
  NSURL *destinationURL = [NSURL fileURLWithPath:@"/usr/bin/pod-binstub"];

  // Unless explicitely triggered by user, try to determine if we should continue.
  if (sender == nil) {
    if (access(destinationURL.fileSystemRepresentation, X_OK) == 0) {
      NSLog(@"Already installed binstub.");
      return;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CPHaveAskedUserToInstallTool"]) {
      NSLog(@"Asking the user to install the binstub again is prohibited.")
      return;
    }
  }

  destinationURL = [self runModalInstallationRequestAlert:destinationURL];
  if (destinationURL) {
    [self installBinstub:destinationURL];
  }
}

#pragma mark - Utility

// Never ask the user to automatically install again.
//
- (void)setDoNotRequestInstallationAgain;
{
  NSLog(@"Not going to automatically request binstub installation anymore.");
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CPHaveAskedUserToInstallTool"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - User interaction (modal windows)

// Allows the user to select a different destination.
//
// Returns either the `suggestedDestination`, a newly selected destination, or nil in case the user
// chose to cancel.
//
// In case the user chose to cancel the operation, this preference is stored and the user will not
// be automatically asked to install again on the next launch.
//
- (NSURL *)runModalInstallationRequestAlert:(NSURL *)suggestedDestinationURL;
{
  NSString *destinationFilename = suggestedDestinationURL.lastPathComponent;
  NSURL *destinationDirURL = [suggestedDestinationURL URLByDeletingLastPathComponent];

  NSAlert *alert = [NSAlert new];
  alert.alertStyle = NSInformationalAlertStyle;
  alert.messageText = NSLocalizedString(@"INSTALL_CLI_MESSAGE_TEXT", nil);
  NSString *formatString = NSLocalizedString(@"INSTALL_CLI_INFORMATIVE_TEXT", nil);
  alert.informativeText = [NSString stringWithFormat:formatString, destinationFilename];
  formatString = NSLocalizedString(@"INSTALL_CLI", nil);
  [alert addButtonWithTitle:[NSString stringWithFormat:formatString, destinationDirURL.path]];
  [alert addButtonWithTitle:NSLocalizedString(@"INSTALL_CLI_ALTERNATE_DESTINATION", nil)];
  [alert addButtonWithTitle:NSLocalizedString(@"INSTALL_CLI_CANCEL", nil)];

  switch ([alert runModal]) {
    case NSAlertSecondButtonReturn:
      destinationDirURL = [self runModalDestinationOpenPanel:destinationDirURL];
      if (destinationDirURL == nil) {
        [self setDoNotRequestInstallationAgain];
        return nil;
      }
      break;
    case NSAlertThirdButtonReturn:
      [self setDoNotRequestInstallationAgain];
      return nil;
  }

  return [destinationDirURL URLByAppendingPathComponent:destinationFilename];
}

// Allows the user to choose a different destination than the suggested destination.
//
// Returns either the `suggestedDirectoryURL`, a newly selected destination, or nil in case the user
// chose to cancel.
//
- (NSURL *)runModalDestinationOpenPanel:(NSURL *)suggestedDirectoryURL;
{
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  openPanel.canChooseFiles = NO;
  openPanel.canChooseDirectories = YES;
  openPanel.canCreateDirectories = YES;
  openPanel.showsHiddenFiles = YES;
  openPanel.resolvesAliases = YES;
  openPanel.allowsMultipleSelection = NO;
  openPanel.directoryURL = suggestedDirectoryURL;
  if ([openPanel runModal] == NSFileHandlingPanelCancelButton) {
    return nil;
  }
  return openPanel.URLs[0];
}

#pragma mark - Binstub installation

// Tries to install the binstub to `destinationURL` by asking the user for authorization to write to
// the destination first.
//
// Because the user might have selected an alternate destination, and persisting that location leads
// to more complex rules about when to request for installation again, we configure the application to
// never again request for installation once succeeded.
//
// Do *not* store this earlier, because authorization or writing might fail before it's succeeded in
// which case the user should be requested for installation again on the next launch.
//
- (void)installBinstub:(NSURL *)destinationURL;
{
  const char *destination_path = destinationURL.fileSystemRepresentation;
  NSLog(@"Try to install binstub to `%s`.", destination_path);

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
    return;
  }

  // Serialize the AuthorizationRef so it can be passed to the `authopen` tool.
  AuthorizationRef authorizationRef = [authorization authorizationRef];
  AuthorizationExternalForm serializedRef;
  OSStatus serialized = AuthorizationMakeExternalForm(authorizationRef, &serializedRef);
  if (serialized != errAuthorizationSuccess) {
    NSLog(@"Failed to serialize AuthorizationRef (%d)", serialized);
    return;
  }

  // Create a pipe through the `authopen` tool that allows file creation and
  // writing to the destination and also marks the file as being executable.
  char command[1024];
  sprintf(command, "/usr/libexec/authopen -extauth -c -m 0755 -w %s", destination_path);
  errno = 0;
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
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"pod" ofType:nil];
    FILE *source_file = fopen([sourcePath UTF8String], "r");
    if (source_file == NULL) {
      NSLog(@"Failed to open `%@` (%d - %s)", sourcePath, errno, strerror(errno));
    } else {
      NSLog(@"Write contents of `%@` to destination.", sourcePath);
      int c;
      while ((c = fgetc(source_file)) != EOF) {
        fwrite(&c, 1, 1, destination_pipe);
      }
      fclose(source_file);
      NSLog(@"Successfully wrote binstub to destination.");
      [self setDoNotRequestInstallationAgain];
    }
    pclose(destination_pipe);
  }
}

@end
