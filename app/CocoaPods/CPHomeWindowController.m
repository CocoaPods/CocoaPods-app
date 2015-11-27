#import "CPHomeWindowController.h"
#import "CPRecentDocumentsController.h"

#pragma mark -

@interface CPHomeWindowController ()

@property (strong) IBOutlet CPRecentDocumentsController *recentDocumentsController;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *cocoapodsVersionTextField;

@end

@implementation CPHomeWindowController

- (instancetype)init;
{
  return [super initWithWindowNibName:@"CPHomeWindowController"];
}

- (void)windowDidLoad;
{
  self.window.excludedFromWindowsMenu = YES;

  [self.tableView setTarget:self];
  [self.tableView setDoubleAction:@selector(didDoubleTapOnRecentItem:)];

  NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  self.cocoapodsVersionTextField.stringValue = versionNumber;
}

- (void)didDoubleTapOnRecentItem:(NSTableView *)sender {
  NSInteger row = [sender selectedRow];

  CPHomeWindowDocumentEntry *item = self.recentDocumentsController.recentDocuments[row];

  NSDocumentController *controller = [NSDocumentController sharedDocumentController];
  [controller openDocumentWithContentsOfURL:item.podfileURL display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
    [self.window orderOut:self];
  }];
}


@end
