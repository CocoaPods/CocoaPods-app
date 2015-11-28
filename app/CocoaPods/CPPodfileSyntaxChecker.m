//
//  CPPodfileSyntaxChecker.m
//  CocoaPods
//
//  Created by Orta on 11/27/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import "RBObject+CocoaPods.h"
#import "CPPodfileSyntaxChecker.h"
#import "CocoaPods-Swift.h"

#import <Fragaria/Fragaria.h>
#import <Fragaria/SMLSyntaxError.h>

@interface CPPodfileSyntaxChecker()

@property (weak) MGSFragariaView *editor;
@property (weak) CPPodfileEditorViewController *editorViewController;

@end

@implementation CPPodfileSyntaxChecker

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


static SMLSyntaxError * _Nullable
SyntaxErrorFromException(NSException * _Nonnull exception)
{
  NSString *location = [exception.userInfo[@"backtrace"] firstObject];

  if ([location componentsSeparatedByString:@":"].count < 2) { return nil; }
  NSInteger lineNumber = [location componentsSeparatedByString:@":"][1].integerValue;

  // Example:
  //
  // Invalid `Podfile` file: Pod::DSLError
  // syntax error, unexpected tSTRING_BEG, expecting keyword_do or '{' or '('
  // {source 'https://github.com/artsy/Specs.git'
  //          ^

  RBObject *rubyException = exception.userInfo[@"$!"];
  NSArray *result = [rubyException send:@"parse_line_number_from_description"];
  NSArray *lines = [result.lastObject componentsSeparatedByString:@"\n"];

  // TODO Pod::DSLError#parse_line_number_from_description is a private method. Make it public?

  VALUE descriptionValue = rb_funcall(rubyException.__rbobj__, rb_intern("description"), 0);
  NSString *description = @(StringValuePtr(descriptionValue));

  if (lines.count > 1) {
    // Skip first line.
    description = [[lines subarrayWithRange:NSMakeRange(1, lines.count-1)] componentsJoinedByString:@"\n"];
  } else {
    description = result.lastObject;
  }

  return [SMLSyntaxError errorWithDescription:description ofLevel:kMGSErrorCategoryError atLine:lineNumber];
}

@end
