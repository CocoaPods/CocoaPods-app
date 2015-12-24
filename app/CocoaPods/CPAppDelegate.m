#import "CPAppDelegate.h"
#import "CPCLIToolInstallationController.h"
#import "CPHomeWindowController.h"
#import "CPReflectionServiceProtocol.h"
#import "CocoaPods-Swift.h"
#import "CPCLIToolInstallationController.h"

@interface CPAppDelegate ()
@property (nonatomic, strong) CPHomeWindowController *homeWindowController;
@property (strong) NSXPCConnection *reflectionService;
@property (strong) URLHandler *urlHandler;
@end

@implementation CPAppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification;
{
  [self startURLService];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
#ifdef DEBUG
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCPDoNotRequestCLIToolInstallationAgainKey];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCPCLIToolInstalledToDestinationsKey];
#endif
  
  [self startReflectionService];
}

- (void)startReflectionService;
{
  self.reflectionService = [[NSXPCConnection alloc] initWithServiceName:@"org.cocoapods.ReflectionService"];
  self.reflectionService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CPReflectionServiceProtocol)];
  self.reflectionService.invalidationHandler = ^{ NSLog(@"ReflectionService invalidated."); };
  self.reflectionService.interruptionHandler = ^{ NSLog(@"ReflectionService interrupted."); };
  [self.reflectionService resume];
}

- (void)startURLService;
{
  self.urlHandler = [URLHandler new];
  [self.urlHandler registerHandler];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
  return NO;
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
    [self.homeWindowController installBinstub:sender];
}

- (IBAction)showHomeWindow:(id)sender;
{
  if (self.homeWindowController == nil) {
    self.homeWindowController = [[CPHomeWindowController alloc] init];
    [self.homeWindowController.window center];
  }

  [self.homeWindowController showWindow:sender];
}

#pragma mark - Private

- (CPHomeWindowController *)homeWindowController
{
  if (_homeWindowController == nil) {
    _homeWindowController = [[CPHomeWindowController alloc] init];
  }
  return _homeWindowController;
}


@end
