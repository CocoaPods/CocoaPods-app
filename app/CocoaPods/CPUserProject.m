#import "CPUserProject.h"
#import "CocoaPods-Swift.h"
#import "CPMiniPromise.h"

@interface CPUserProject () <CPMiniPromiseDelegate>
@property (strong) NSStoryboard *storyboard;
@property (strong) CPMiniPromise *completionPromise;
@end

@implementation CPUserProject

@synthesize podfilePlugins=_podfilePlugins, xcodeIntegrationDictionary=_xcodeIntegrationDictionary;

- (void)makeWindowControllers
{
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

- (BOOL)shouldFulfillPromise:(CPMiniPromise *)promise
{
  return self.xcodeIntegrationDictionary && self.podfilePlugins;
}

- (void)registerForFullMetadataCallback:(void (^)(void))completion
{
  self.completionPromise = self.completionPromise ?: [CPMiniPromise promiseWithDelegate:self];

  [self.completionPromise addBlock:completion];
  [self.completionPromise checkForFulfillment];
}

- (void)setXcodeIntegrationDictionary:(NSDictionary *)xcodeIntegrationDictionary
{
  _xcodeIntegrationDictionary = xcodeIntegrationDictionary;
  [self.completionPromise checkForFulfillment];
}

- (void)setPodfilePlugins:(NSArray<NSString *> *)podfilePlugins
{
  _podfilePlugins = podfilePlugins;
  [self.completionPromise checkForFulfillment];
}

- (NSString * _Nullable)lockfilePath
{
  NSString *podfileURL = self.fileURL.relativePath;
  NSString *lockfileURL = [podfileURL stringByAppendingString:@".lock"];
  if ([[NSFileManager defaultManager] fileExistsAtPath:lockfileURL]) {
    return lockfileURL;
  }
  return nil;
}

#pragma mark - NSFilePresenter

- (void)presentedItemDidChange
{
  NSError *error;
  [self readFromURL:self.fileURL ofType:self.fileType error:&error];
  
  if (!error) {
    if ( [self.delegate respondsToSelector: @selector(contentDidChangeinUserProject:)] ) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate contentDidChangeinUserProject:self];
      });
    }
  }
}

@end
