#import "RBObject+CocoaPods.h"
#import "CPPodfileReflection.h"
#import "CocoaPods-Swift.h"

#import <Fragaria/Fragaria.h>
#import <Fragaria/SMLSyntaxError.h>

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
  [self performSelector:@selector(parsePodfile) withObject:nil afterDelay:1];
}

- (void)parsePodfile;
{
  CPUserProject *project = self.editorViewController.podfileViewController.userProject;
  NSURL *fileURL = project.fileURL;

  [RBObject performBlock:^{
    RBPathname *pathname = [RBObjectFromString(@"Pathname") new:fileURL.path];

    @try {
      RBPodfile *podfile = [RBObjectFromString(@"Pod::Podfile") from_ruby:pathname :project.contents];
      NSArray *plugins = podfile.plugins.allKeys;
      dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Podfile Plugins: %@", plugins);
        project.podfilePlugins = plugins;
        // Clear any previous syntax errors.
        self.editor.syntaxErrors = nil;
      });
    }

    @catch (NSException *exception) {
      // In case of a Pod::DSLError, try to create a UI syntax error out of it.
      if (![exception.reason isEqualToString:@"Pod::DSLError"]) {
        @throw;
      }
      SMLSyntaxError *syntaxError = SyntaxErrorFromException(exception);
      if (syntaxError) {
        dispatch_async(dispatch_get_main_queue(), ^{
          self.editor.syntaxErrors = @[syntaxError];
        });
      }
    }

  } error:^(NSError * _Nonnull error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSAlert alertWithError:error] beginSheetModalForWindow: self.editor.window
                                             completionHandler:nil];
    });
  }];
}

// TODO: have CocoaPods-Core keep the error message around
//       https://cocoapods.slack.com/archives/cocoapods-app/p1448669896000284

static SMLSyntaxError * _Nullable
SyntaxErrorFromException(NSException * _Nonnull exception)
{
  NSString *location = [exception.userInfo[@"backtrace"] firstObject];
  if ([location componentsSeparatedByString:@":"].count < 2) { return nil; }
  NSInteger lineNumber = [location componentsSeparatedByString:@":"][1].integerValue;

  RBObject *rubyException = exception.userInfo[@"$!"];
  // TODO -[RBObject description] returns the description of the proxy.
  VALUE descriptionValue = rb_funcall(rubyException.__rbobj__, rb_intern("description"), 0);
  // Example:
  //     Invalid `Podfile` file: undefined local variable or method `s' for #<Pod::Podfile:0x0000010331f390>
  NSString *description = @(StringValuePtr(descriptionValue));
  NSArray *descriptionArray = [description componentsSeparatedByString:@"` file: "];

  if (descriptionArray.count < 2) { description = descriptionArray[1]; }

  NSString *firstCharacter = [[description substringToIndex:1] uppercaseString];
  description = [firstCharacter stringByAppendingString:[description substringFromIndex:1]];

  return [SMLSyntaxError errorWithDescription:description ofLevel:kMGSErrorCategoryError atLine:lineNumber];
}

@end
