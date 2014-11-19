#import "CPUserProject.h"
#import <Fragaria/MGSFragariaFramework.h>

@interface CPUserProject ()
@property (weak) IBOutlet NSView *containerView;
@property (strong) MGSFragaria *editor;
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

  self.editor = [MGSFragaria new];
  [self.editor setObject:self forKey:MGSFODelegate];
  [self.editor setSyntaxColoured:YES];
  [self.editor setSyntaxDefinitionName:@"Ruby"];
  [self.editor embedInView:self.containerView];
  [self.editor setString:self.contents];

  NSTextView *textView = [self.editor objectForKey:ro_MGSFOTextView];
  self.undoManager = textView.undoManager;
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
  return [self.contents writeToURL:absoluteURL
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:outError];
}

- (void)textDidChange:(NSNotification *)notification;
{
  NSTextView *textView = notification.object;
  self.contents = textView.string;

}

@end
