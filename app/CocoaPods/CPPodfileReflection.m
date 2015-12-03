#import "RBObject+CocoaPods.h"
#import "CPPodfileReflection.h"
#import "CocoaPods-Swift.h"
#import "CPReflectionServiceProtocol.h"

#import <Fragaria/Fragaria.h>
#import <Fragaria/SMLSyntaxError.h>

#import "CPAppDelegate.h"

@interface CPPodfileReflection()

@property (weak) MGSFragariaView *editor;
@property (weak) CPPodfileEditorViewController *editorViewController;

@end

@implementation CPPodfileReflection

- (instancetype)initWithPodfileEditorVC:(CPPodfileEditorViewController *)editor fragariaEditor:(MGSFragariaView *)fragaria
{
  self = [super init];
  if (!self) { return nil; }

  _editor = fragaria;
  _editorViewController = editor;

  return self;
}

- (void)textDidChange:(NSNotification *)notification;
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(parsePodfile) object:nil];
  [self performSelector:@selector(parsePodfile) withObject:nil afterDelay:0.5];
}

- (void)parsePodfile;
{
  CPUserProject *project = self.editorViewController.podfileViewController.userProject;

  NSXPCConnection *reflectionService = [(CPAppDelegate *)NSApp.delegate reflectionService];
  [reflectionService.remoteObjectProxy pluginsFromPodfile:project.contents
                                                withReply:^(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (plugins) {
        project.podfilePlugins = plugins;
        // Clear any previous syntax errors.
        self.editor.syntaxErrors = nil;

      } else if ([error.userInfo[CPErrorName] isEqualToString:@"Pod::DSLError"]) {
        SMLSyntaxError *syntaxError = SyntaxErrorFromError(error);
        if (syntaxError) {
          self.editor.syntaxErrors = @[syntaxError];
        }

      } else {
        [[NSAlert alertWithError:error] beginSheetModalForWindow:self.editor.window
                                               completionHandler:nil];
      }
    });
  }];
}

static SMLSyntaxError * _Nullable
SyntaxErrorFromError(NSError * _Nonnull error)
{
  NSString *location = [error.userInfo[CPErrorRubyBacktrace] firstObject];
  if ([location componentsSeparatedByString:@":"].count < 2) { return nil; }
  NSInteger lineNumber = [location componentsSeparatedByString:@":"][1].integerValue;

  return [SMLSyntaxError errorWithDescription:error.localizedRecoverySuggestion
                                      ofLevel:kMGSErrorCategoryError
                                       atLine:lineNumber];
}

@end
