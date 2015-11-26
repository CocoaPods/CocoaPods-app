#import "CPUserProject.h"

#import <Fragaria/Fragaria.h>
#import <ANSIEscapeHelper/AMR_ANSIEscapeHelper.h>

#import <objc/runtime.h>

#import "CPANSIEscapeHelper.h" 
#import "CPCLITask.h"

#import "CocoaPods-Swift.h"

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 1090
enum {
   NSModalResponseStop                 = (-1000),
   NSModalResponseAbort                = (-1001),
   NSModalResponseContinue             = (-1002),
};
typedef NSInteger NSModalResponse;
#endif

@interface CPUserProject () <CPCLITaskDelegate, NSTextViewDelegate>

// Such sin.
// TODO: Add real custom window controllers.
@property (strong) IBOutlet NSWindow *progressWindow;
@property (assign) IBOutlet NSTextView *progressOutputView;

@property (strong) IBOutlet MGSFragariaView *editor;

@property (strong) NSStoryboard *storyboard;
@property (strong) CPCLITask *task;
@end

@implementation CPUserProject

- (void)makeWindowControllers {
  self.storyboard = [NSStoryboard storyboardWithName:@"Podfile" bundle:nil];

  NSWindowController *windowController = [self.storyboard instantiateControllerWithIdentifier:@"Podfile Editor"];

  CPPodfileViewController *podfileVC = (id)windowController.contentViewController;
  podfileVC.userProject = self;

  /// This could move into a CPPodfileWindowController?
  NSWindow *window = windowController.window;
  window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
  window.titleVisibility = NSWindowTitleHidden;
  window.titlebarAppearsTransparent = YES;
  window.movableByWindowBackground = YES;

  [self addWindowController:windowController];
}

#pragma mark - Persistance

- (BOOL)readFromURL:(NSURL *)absoluteURL
             ofType:(NSString *)typeName
              error:(NSError **)outError;
{
  if ([[absoluteURL lastPathComponent] isEqualToString:@"Podfile"]) {
    self.contents = [NSString stringWithContentsOfURL:absoluteURL
                                             encoding:NSUTF8StringEncoding
                                                error:outError];
    if (self.contents != nil) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL
            ofType:(NSString *)typeName
             error:(NSError **)outError;
{
  return [self.contents writeToURL:absoluteURL
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:outError];
}

#pragma mark - Progress sheet

+ (NSSet *)keyPathsForValuesAffectingProgressButtonTitle;
{
  return [NSSet setWithObject:@"task.progress.fractionCompleted"];
}

- (NSString *)progressButtonTitle;
{
  return self.task.progress.fractionCompleted == 1.0f ? @"Done" : @"Cancel";
}

- (void)presentProgressSheet;
{
  NSWindowController *controller = self.windowControllers[0];
  [controller.window beginSheet:self.progressWindow completionHandler:nil];
}

- (IBAction)dismissProgressSheet:(id)sender;
{
  if (self.task.running) {
    [self.task cancel];
  }
  
  [NSApp endSheet:self.progressWindow returnCode:NSModalResponseStop];

  [self.progressWindow orderOut:self];
  // Reset the sheet /after/ it has been removed from screen.
  dispatch_async(dispatch_get_main_queue(), ^{
    [self resetSheet];
  });

}

- (void)resetSheet;
{
  self.task = nil;
  self.progressOutputView.string = @"";
}

#pragma mark - Command execution

- (IBAction)updatePods:(id)sender;
{
  [self executeTaskWithCommand:@"update"];
}

- (IBAction)installPods:(id)sender;
{
  [self executeTaskWithCommand:@"install"];
}

- (void)executeTaskWithCommand:(NSString *)command
{
  self.task = [[CPCLITask alloc] initWithUserProject:self
                                             command:command
                                            delegate:self
                                    qualityOfService:NSQualityOfServiceUtility];
  [self.task run];
  
  [self presentProgressSheet];
}

#pragma mark - CPCLITaskDelegate

- (void)task:(CPCLITask *)task didUpdateOutputContents:(NSAttributedString *)updatedOutput
{
  // Determine if we're at the tail of the output log (and should scroll) before we append more to it.
  CGRect visibleRect = self.progressOutputView.enclosingScrollView.documentVisibleRect;
  CGFloat maxContentOffset = self.progressOutputView.bounds.size.height - visibleRect.size.height;
  BOOL scrolledToBottom = visibleRect.origin.y == maxContentOffset;

  [self.progressOutputView.textStorage setAttributedString:updatedOutput];

  // Keep the text view at the bottom if it was previously, otherwise restore the previous position.
  if (scrolledToBottom) {
    [self.progressOutputView scrollToEndOfDocument:self];
  } else {
    [self.progressOutputView scrollPoint:visibleRect.origin];
  }
}

@end
