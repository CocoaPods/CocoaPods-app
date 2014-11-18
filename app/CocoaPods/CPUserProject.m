#import "CPUserProject.h"
#import <Fragaria/MGSFragariaFramework.h>

@interface CPUserProject ()
@property (weak) IBOutlet NSView *containerView;
@property (strong) MGSFragaria *fragaria;
@property (strong) NSString *contents;
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
  // [self.fragaria setObject:self forKey:MGSFODelegate];
  [self.fragaria setSyntaxColoured:YES];
  [self.fragaria setSyntaxDefinitionName:@"Ruby"];
  [self.fragaria embedInView:self.containerView];
  [self.fragaria setString:self.contents];
}

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
  NSLog(@"Save to %@", absoluteURL);
  return YES;
}

+ (BOOL)autosavesInPlace;
{
    return YES;
}

@end
