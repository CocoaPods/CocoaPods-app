#import "CPAppDelegate.h"
#import "CPCLIToolInstallationController.h"
#import "CPHomeWindowController.h"

NSString * const kCPCLIToolSuggestedDestination = @"/usr/local/bin/pod";

@interface CPAppDelegate ()
@property (strong) CPHomeWindowController *homeWindowController;
@end

@implementation CPAppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
#ifdef DEBUG
  //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCPRequestCLIToolInstallationAgainKey];
  //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCPCLIToolInstalledToDestinationsKey];
  //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CPShowVerboseCommandOutput"];
  //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
#endif

  [[self CLIToolInstallationController] installBinstubIfNecessary];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
  // Show the home window when there's no active Podfile edits going on
  if ([NSApp orderedDocuments].count == 0) {
    [self showHomeWindow:self];
  }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;
{
  [self showHomeWindow:sender];
  return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)hasVisibleWindows
{
  // When the dock icon is clicked, show the home window if there are no other windows open
  if (!hasVisibleWindows) {
    [self showHomeWindow:sender];
  }

  return YES;
}

#pragma mark - Actions

- (IBAction)installBinstubIfNecessary:(id)sender;
{
  [[self CLIToolInstallationController] installBinstub];
}

- (IBAction)showHomeWindow:(id)sender;
{
  if (self.homeWindowController == nil) {
    self.homeWindowController = [[CPHomeWindowController alloc] init];
  }

  [self.homeWindowController showWindow:sender];
  [self.homeWindowController.window center];
}

#pragma mark - Private

- (CPCLIToolInstallationController *)CLIToolInstallationController;
{
  NSURL *destinationURL = [NSURL fileURLWithPath:kCPCLIToolSuggestedDestination];
  return [CPCLIToolInstallationController controllerWithSuggestedDestinationURL:destinationURL];
}

@end
