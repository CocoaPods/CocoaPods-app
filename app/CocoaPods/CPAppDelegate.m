#import "CPAppDelegate.h"
#import "CPCLIToolInstallationController.h"
#import "CPHomeWindowController.h"
#import "CPReflectionServiceProtocol.h"
#import "CocoaPods-Swift.h"
#import "CPCLIToolInstallationController.h"
#import <Quartz/Quartz.h>
#import <LetsMove/PFMoveApplication.h>

@interface CPAppDelegate ()
@property (nonatomic, strong) CPHomeWindowController *homeWindowController;
@property (strong) NSXPCConnection *reflectionService;
@property (strong) URLHandler *urlHandler;
@end

@implementation CPAppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification;
{
  PFMoveToApplicationsFolderIfNecessary();
  [self startURLService];
  [self checkForBirthday];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
#ifdef DEBUG
//  NSLog(@"Ensuring you see the install CLI-tools banner");
//  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCPDoNotRequestCLIToolInstallationAgainKey];
//  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCPCLIToolInstalledToDestinationsKey];
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

#pragma mark - Easter Eggs

- (void)checkForBirthday
{
  NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
  if (components.month == 8 && components.day == 13) {
    NSApplication *app = [NSApplication sharedApplication];
    NSImage *appIcon = [app applicationIconImage];
    [app setApplicationIconImage:[self editionColoredImage:appIcon]];
  }
}

- (NSImage *)editionColoredImage:(NSImage *)image
{
  CIImage *inputImage = [[CIImage alloc] initWithData:image.TIFFRepresentation];

  CIFilter *hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
  [hueAdjust setValue: inputImage forKey: @"inputImage"];

  NSNumber *colorValue = @(365.375);
  [hueAdjust setValue:colorValue forKey: @"inputAngle"];

  CIImage *outputImage = hueAdjust.outputImage;
  NSImage *resultImage = [[NSImage alloc] initWithSize:outputImage.extent.size];
  NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:outputImage];
  [resultImage addRepresentation:rep];

  return resultImage;
}

@end
