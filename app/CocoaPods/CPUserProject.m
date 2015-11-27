#import "CPUserProject.h"

#import <ANSIEscapeHelper/AMR_ANSIEscapeHelper.h>

#import <objc/runtime.h>

#import "CPANSIEscapeHelper.h"

#import "CocoaPods-Swift.h"
#import "RBObject+CocoaPods.h"

@interface CPUserProject ()
@property (strong) NSStoryboard *storyboard;
@end


@interface CPUserProject ()
@end

@implementation CPUserProject

- (void)makeWindowControllers {
  if (self.fileURL == nil) {
    NSLog(@"HRM?");
    return;
  }

  self.storyboard = [NSStoryboard storyboardWithName:@"Podfile" bundle:nil];

  NSWindowController *windowController = [self.storyboard instantiateControllerWithIdentifier:@"Podfile Editor"];
  CPPodfileViewController *podfileVC = (id)windowController.contentViewController;
  podfileVC.userProject = self;

  [self addWindowController:windowController];

}



#pragma mark - Persistance

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError;
{
  if ([[absoluteURL lastPathComponent] isEqualToString:@"Podfile"]) {
    self.contents = [NSString stringWithContentsOfURL:absoluteURL encoding:NSUTF8StringEncoding error:outError];
    if (self.contents != nil) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError;
{
  return [self.contents writeToURL:absoluteURL atomically:YES encoding:NSUTF8StringEncoding error:outError];
}


@end
