#import "AppDelegate.h"
#import <SecurityFoundation/SFAuthorization.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
  [self installBinstubIfNecessary:nil];
}

#pragma mark -

- (IBAction)installBinstubIfNecessary:(id)sender;
{
  // TODO change this to just `pod` for real release and then also update the
  // `sprintf` calls to `snprintf` with hardcoded lengths.
  const char *destination_path = "/usr/bin/pod-binstub";

  if (access(destination_path, X_OK) == 0) {
    NSLog(@"Already installed binstub.");
    return;
  }

  NSAlert *alert = [NSAlert new];
  alert.alertStyle = NSInformationalAlertStyle;
  alert.messageText = @"Install CLI binstub tool.";
  alert.informativeText = [NSString stringWithFormat:@"In order to easily access the standalone CocoaPods bundle a tool will be installed to `%s`.", destination_path];
  [alert addButtonWithTitle:@"OK"];
  [alert addButtonWithTitle:@"Cancel"];
  if ([alert runModal] == NSAlertSecondButtonReturn) {
    NSLog(@"Cancelled by user.");
    return;
  }

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
  OSStatus serialized = AuthorizationMakeExternalForm(authorizationRef,
                                                      &serializedRef);
  if (serialized != errAuthorizationSuccess) {
    NSLog(@"Failed to serialize AuthorizationRef (%d)", serialized);
    return;
  }

  // Create a pipe through the `authopen` tool that allows file creation and
  // writing to the destination and also marks the file as being executable.
  char command[1024];
  sprintf(command, "/usr/libexec/authopen " \
                   "-extauth -c -m 0755 " \
                   "-w %s", destination_path);
  errno = 0;
  FILE *destination = popen(command, "w");
  if (destination == NULL) {
    NSLog(@"Failed to open pipe to `authopen` (%d - %s)", errno,
                                                          strerror(errno));
  } else {
    // First send the pre-authorized and serialized AuthorizationRef so that the
    // `authopen` tool does not need to request authorization from the user,
    // which would lead to the user seeing an authorization dialog from
    // `authopen` instead of this app.
    fwrite(&serializedRef, sizeof(serializedRef), 1, destination);
    fflush(destination);
    // Now write the actual file data.
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"pod"
                                                           ofType:nil];
    FILE *source = fopen([sourcePath UTF8String], "r");
    if (source == NULL) {
      NSLog(@"Failed to open `%@` (%d - %s)", sourcePath,
                                              errno,
                                              strerror(errno));
    } else {
      NSLog(@"Write contents of `%@` to destination.", sourcePath);
      int c;
      while ((c = fgetc(source)) != EOF) {
        fwrite(&c, 1, 1, destination);
      }
      fclose(source);
      NSLog(@"Successfully wrote binstub to destination.");
    }
    pclose(destination);
  }
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
