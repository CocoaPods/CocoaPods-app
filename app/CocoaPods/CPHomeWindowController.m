#import "CPHomeWindowController.h"

@interface CPHomeWindowDocumentEntry : NSObject <NSCopying>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *podfileURL;
@property (nonatomic, copy) NSImage *image;
@property (nonatomic, copy) NSString *folderPath;
@end

@implementation CPHomeWindowDocumentEntry

- (instancetype)copyWithZone:(NSZone *)zone {
  CPHomeWindowDocumentEntry *copy = [[[self class] allocWithZone:zone] init];
  if (copy) {
    [copy setName:[self.name copyWithZone:zone]];
    [copy setPodfileURL:[self.podfileURL copyWithZone:zone]];
    [copy setImage:[self.image copyWithZone:zone]];
    [copy setFolderPath:[self.folderPath copyWithZone:zone]];
  }

  return copy;
}

@end

#pragma mark -

@interface CPHomeWindowController ()

@end

@implementation CPHomeWindowController

- (instancetype)init;
{
  return [self initWithWindowNibName:@"CPHomeWindowController"];
}

- (void)windowDidLoad;
{
  self.window.excludedFromWindowsMenu = YES;
}

@end
