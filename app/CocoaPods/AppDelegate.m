#import "AppDelegate.h"
#import <SecurityFoundation/SFAuthorization.h>

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
  [self installBinstubIfNecessary];
}

- (void)installBinstubIfNecessary;
{
  // TODO change this to just `pod` for real release.
  const char *destination_path = "/usr/bin/pod-binstub";

  if (access(destination_path, X_OK) == 0) {
    NSLog(@"Already installed binstub.");
    return;
  }

  NSLog(@"Try to install binstub to `%s`.", destination_path);

  // Configure requested authorization.
  char name[1024];
  sprintf(name, "sys.openfile.readwritecreate.%s", destination_path);
  AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed |
                             kAuthorizationFlagExtendRights |
                             kAuthorizationFlagPreAuthorize;
  AuthorizationEnvironment *env = kAuthorizationEmptyEnvironment;

  AuthorizationItem item = { name, 0, NULL, 0};
  AuthorizationRights rights = { 1, &item };

  // Request the user for authorization.
  SFAuthorization *authorization;
  authorization = [SFAuthorization authorizationWithFlags:flags
                                                   rights:&rights
                                              environment:env];

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

@end
