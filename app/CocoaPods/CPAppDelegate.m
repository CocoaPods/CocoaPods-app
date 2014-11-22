#import "CPAppDelegate.h"
#import "CPCLIToolInstallationController.h"

NSString * const kCPCLIToolSuggestedDestination = @"/usr/bin/pod-binstub";

@interface CPAppDelegate ()
@end

@implementation CPAppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
  // [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCPRequestCLIToolInstallationAgainKey];
  // [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CPShowVerboseCommandOutput"];
  // NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

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

#pragma mark - Private

- (CPCLIToolInstallationController *)CLIToolInstallationController;
{
  NSURL *destinationURL = [NSURL fileURLWithPath:kCPCLIToolSuggestedDestination];
  return [CPCLIToolInstallationController controllerWithSuggestedDestinationURL:destinationURL];
}

@end
