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
  [[self CLIToolInstallationController] installBinstub];
}

- (IBAction)showHomeWindow:(id)sender;
{
  if (self.homeWindowController == nil) {
    self.homeWindowController = [[CPHomeWindowController alloc] init];
  }

  [self.homeWindowController showWindow:sender];
}

#pragma mark - Private

- (CPCLIToolInstallationController *)CLIToolInstallationController;
{
  NSURL *destinationURL = [NSURL fileURLWithPath:kCPCLIToolSuggestedDestination];
  return [CPCLIToolInstallationController controllerWithSuggestedDestinationURL:destinationURL];
}

@end
