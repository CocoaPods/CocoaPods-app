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

#pragma mark -

- (IBAction)installBinstubIfNecessary:(id)sender;
{
  // TODO change this to just `pod` for real release and then also update the
  // `sprintf` calls to `snprintf` with hardcoded lengths.
  NSURL *destination = [NSURL fileURLWithPath:@"/usr/bin/pod-binstub"];

  // Unless explicitely triggered by user, try to determine if we should continue.
  if (sender == nil) {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CPHaveAskedUserToInstallTool"]) {
      return;
    }
    if (access(destination.fileSystemRepresentation, X_OK) == 0) {
      NSLog(@"Already installed binstub.");
      return;
    }
  }

  NSString *destinationFilename = destination.lastPathComponent;
  NSURL *destinationDir = [destination URLByDeletingLastPathComponent];

  NSAlert *alert = [NSAlert new];
  alert.alertStyle = NSInformationalAlertStyle;
  alert.messageText = NSLocalizedString(@"INSTALL_CLI_MESSAGE_TEXT", nil);
  alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"INSTALL_CLI_INFORMATIVE_TEXT", nil), destinationFilename];
  [alert addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"INSTALL_CLI", nil), destinationDir.path]];
  [alert addButtonWithTitle:NSLocalizedString(@"INSTALL_CLI_ALTERNATE_DESTINATION", nil)];
  [alert addButtonWithTitle:NSLocalizedString(@"INSTALL_CLI_CANCEL", nil)];

  switch ([alert runModal]) {
    case NSAlertSecondButtonReturn:
      NSLog(@"Select alternate destination!");
      destinationDir = [self runModalDestinationOpenPanel:destinationDir];
      if (destinationDir == nil) {
        NSLog(@"Cancelled by user.");
        [self setDoNotRequestInstallationAgain];
        return;
      }
      break;
    case NSAlertThirdButtonReturn:
      NSLog(@"Cancelled by user.");
      [self setDoNotRequestInstallationAgain];
      return;
  }

  destination = [destinationDir URLByAppendingPathComponent:destinationFilename];
  const char *destination_path = destination.fileSystemRepresentation;

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

- (void)setDoNotRequestInstallationAgain;
{
  // Never ask the user to automatically install again.
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CPHaveAskedUserToInstallTool"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURL *)runModalDestinationOpenPanel:(NSURL *)startingDirectoryURL;
{
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  openPanel.canChooseFiles = NO;
  openPanel.canChooseDirectories = YES;
  openPanel.canCreateDirectories = YES;
  openPanel.showsHiddenFiles = YES;
  openPanel.resolvesAliases = YES;
  openPanel.allowsMultipleSelection = NO;
  openPanel.directoryURL = startingDirectoryURL;
  if ([openPanel runModal] == NSFileHandlingPanelCancelButton) {
    return nil;
  }
  return openPanel.URLs[0];
}

- (IBAction)openGuides:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guides.cocoapods.org/"]];
}

- (IBAction)openPodspecReference:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guides.cocoapods.org/syntax/podspec.html"]];
}

- (IBAction)openPodfileReference:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guides.cocoapods.org/syntax/podfile.html"]];
}

@end
