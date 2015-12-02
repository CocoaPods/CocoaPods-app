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
        NSLog(@"Podfile Plugins: %@", plugins);
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
  NSInteger lineNumber = -1;
  NSString *description = error.localizedRecoverySuggestion;

  NSString *causeName = error.userInfo[CPErrorCauseName];
  if (causeName && [causeName isEqualToString:@"SyntaxError"]) {
    // Example:
    //
    // Podfile:32: syntax error, unexpected tSTRING_BEG, expecting keyword_do or '{' or '('
    //  target 'Artsy' do
    //          ^
    // Podfile:32: syntax error, unexpected keyword_do, expecting end-of-input
    NSScanner *scanner = [NSScanner scannerWithString:description];
    // For some reason, this message is sometimes preceded by "Pod::DSLError\n"
    [scanner scanUpToString:@"Podfile" intoString:NULL];
    [scanner scanString:@"Podfile:" intoString:NULL];
    [scanner scanInteger:&lineNumber];
    [scanner scanString:@": " intoString:NULL];
    description = [description substringFromIndex:scanner.scanLocation];
  } else {
    NSString *location = [error.userInfo[CPErrorRubyBacktrace] firstObject];
    if ([location componentsSeparatedByString:@":"].count < 2) { return nil; }
    lineNumber = [location componentsSeparatedByString:@":"][1].integerValue;
  }

  NSString *firstCharacter = [[description substringToIndex:1] uppercaseString];
  description = [firstCharacter stringByAppendingString:[description substringFromIndex:1]];

  return [SMLSyntaxError errorWithDescription:description
                                      ofLevel:kMGSErrorCategoryError
                                       atLine:lineNumber];
}

@end
