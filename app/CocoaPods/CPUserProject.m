#import "CPUserProject.h"
#import <Fragaria/MGSFragariaFramework.h>

@interface CPUserProject ()
@property (weak) IBOutlet NSView *containerView;
@property (strong) MGSFragaria *fragaria;
@end

@implementation CPUserProject

- (NSString *)windowNibName;
{
  return @"CPUserProject";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller;
{
  [super windowControllerDidLoadNib:controller];

  self.fragaria = [MGSFragaria new];
  // [self.fragaria setObject:self forKey:MGSFragaria];
  [self.fragaria setSyntaxColoured:YES];
  [self.fragaria setSyntaxDefinitionName:@"Ruby"];
  [self.fragaria embedInView:self.containerView];
  [self.fragaria setString:@"# We don't need the future."];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL
             ofType:(NSString *)typeName
              error:(NSError **)outError;
{
  NSLog(@"Open: %@", absoluteURL);
  return [[absoluteURL lastPathComponent] isEqualToString:@"Podfile"];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL
            ofType:(NSString *)typeName
             error:(NSError **)outError;
{
  NSLog(@"Save to %@", absoluteURL);
  return YES;
}

+ (BOOL)autosavesInPlace;
{
    return YES;
}

@end
