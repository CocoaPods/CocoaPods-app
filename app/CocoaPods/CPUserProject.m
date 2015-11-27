#import "CPUserProject.h"

#import <Fragaria/Fragaria.h>
#import <Fragaria/SMLSyntaxError.h>
#import <ANSIEscapeHelper/AMR_ANSIEscapeHelper.h>

#import <objc/runtime.h>

#import "CPANSIEscapeHelper.h" 
#import "CPCLITask.h"

#import "RBObject+CocoaPods.h"

static SMLSyntaxError * _Nullable
SyntaxErrorFromException(NSException * _Nonnull exception)
{
  RBObject *rubyException = exception.userInfo[@"$!"];

  // TODO Pod::DSLError#parse_line_number_from_description is a private method. Make it public?
  NSArray *result = [rubyException send:@"parse_line_number_from_description"];
  NSString *location = result.firstObject;
  if ([location isEqual:[NSNull null]]) {
    NSLog(@"DSL error has no location info.");
    return nil;
  }
  NSInteger lineNumber = [location componentsSeparatedByString:@":"].lastObject.integerValue;

  // Example:
  //
  // Invalid `Podfile` file: Pod::DSLError
  // syntax error, unexpected tSTRING_BEG, expecting keyword_do or '{' or '('
  // {source 'https://github.com/artsy/Specs.git'
  //          ^
  NSArray *descriptionLines = [result.lastObject componentsSeparatedByString:@"\n"];
  NSString *description = nil;
  if (descriptionLines.count > 1) {
    // Skip first line.
    description = [[descriptionLines subarrayWithRange:NSMakeRange(1, descriptionLines.count-1)] componentsJoinedByString:@"\n"];
  } else {
    description = result.lastObject;
  }

  return [SMLSyntaxError errorWithDescription:description ofLevel:kMGSErrorCategoryError atLine:lineNumber];
}

// Hack SMLTextView to also consider the leading colon when completing words, which are all the
// symbols that we support.
//
@implementation SMLTextView (CPIncludeLeadingColonsInCompletions)

+ (void)load;
{
  Method m1 = class_getInstanceMethod(self, @selector(rangeForUserCompletion));
  Method m2 = class_getInstanceMethod(self, @selector(CP_rangeForUserCompletion));
  method_exchangeImplementations(m1, m2);
}

-(NSRange)CP_rangeForUserCompletion;
{
  NSRange range = [self CP_rangeForUserCompletion];
  if (range.location != NSNotFound && range.location > 0
      && [self.string characterAtIndex:range.location-1] == ':') {
    range = NSMakeRange(range.location-1, range.length+1);
  }
  return range;
}

@end

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 1090
enum {
   NSModalResponseStop                 = (-1000),
   NSModalResponseAbort                = (-1001),
   NSModalResponseContinue             = (-1002),
};
typedef NSInteger NSModalResponse;
#endif

@interface CPUserProject () <CPCLITaskDelegate, MGSFragariaTextViewDelegate>

// Such sin.
// TODO: Add real custom window controllers.
@property (strong) IBOutlet NSWindow *progressWindow;
@property (assign) IBOutlet NSTextView *progressOutputView;

@property (weak) IBOutlet NSButton *verboseModeButton;
@property (weak) IBOutlet NSButton *podUpdateButton;
@property (weak) IBOutlet NSButton *podInstallButton;

@property (strong) IBOutlet MGSFragariaView *editor;
@property (strong) NSString *contents;
@property (strong) CPCLITask *task;

@property (strong) NSArray *podfilePlugins;
@end

@implementation CPUserProject

- (NSString *)windowNibName;
{
  return @"CPUserProject";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller;
{
  [super windowControllerDidLoadNib:controller];

  // Seeing as this class doesn’t actually implement any drag operation actions, I don’t feel like marking the class
  // as such. It seems like a bit of bug to me that it would be required for a textViewDelegate.
  self.editor.textViewDelegate = (id<MGSFragariaTextViewDelegate, MGSDragOperationDelegate>)self;

  self.editor.syntaxColoured = YES;
  self.editor.syntaxDefinitionName = @"Podfile";
  self.editor.showsSyntaxErrors = YES;
  self.editor.string = self.contents;
  
  self.verboseModeButton.title = NSLocalizedString(@"PODFILE_WINDOW_VERBOSE_SWITCH_TITLE", nil);
  self.podUpdateButton.title = NSLocalizedString(@"PODFILE_WINDOW_POD_UPDATE_BUTTON_TITLE", nil);
  self.podInstallButton.title = NSLocalizedString(@"PODFILE_WINDOW_POD_INSTALL_BUTTON_TITLE", nil);

  self.undoManager = self.editor.textView.undoManager;
}

- (void)textDidChange:(NSNotification *)notification;
{
  NSTextView *textView = notification.object;
  NSString *contents = textView.string;
  self.contents = contents;

  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(parsePodfile) object:nil];
  [self performSelector:@selector(parsePodfile) withObject:nil afterDelay:1];
}

- (void)parsePodfile;
{
  [RBObject performBlock:^{
    RBPathname *pathname = RBObjectFromString([NSString stringWithFormat:@"Pathname.new('%@')", self.fileURL.path]);
    RBPodfile *podfile = nil;

    @try {
      podfile = [RBObjectFromString(@"Pod::Podfile") from_ruby:pathname :self.contents];
    }
    @catch (NSException *exception) {
      if ([exception.reason isEqualToString:@"Pod::DSLError"]) {
        SMLSyntaxError *syntaxError = SyntaxErrorFromException(exception);
        if (syntaxError) {
          dispatch_async(dispatch_get_main_queue(), ^{
            self.editor.syntaxErrors = @[syntaxError];
          });
        }
      }
      return;
    }

    NSArray *plugins = podfile.plugins.allKeys;
    NSLog(@"Plugins: %@", plugins);
    dispatch_async(dispatch_get_main_queue(), ^{
      self.podfilePlugins = plugins;
      // Clear any previous syntax errors.
      self.editor.syntaxErrors = nil;
    });
  }];
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
      [self parsePodfile];
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
  return self.task.progress.fractionCompleted == 1.0f ? NSLocalizedString(@"POD_INSTALL_SHEET_COMPLETED_BUTTON_TITLE", nil) : NSLocalizedString(@"POD_INSTALL_SHEET_IN_PROGRESS_BUTTON_TITLE", nil);
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
