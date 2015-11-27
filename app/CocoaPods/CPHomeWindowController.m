#import "CPHomeWindowController.h"
#import "CPRecentDocumentsController.h"

#pragma mark -

@interface CPHomeWindowController ()

@property (strong) IBOutlet CPRecentDocumentsController *recentDocumentsController;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *cocoapodsVersionTextField;
@property (weak) IBOutlet NSButton *openGuidesButton;
@property (weak) IBOutlet NSButton *openSearchButton;
@property (weak) IBOutlet NSButton *openChangelogButton;

@end

@implementation CPHomeWindowController

- (instancetype)init;
{
  return [super initWithWindowNibName:@"CPHomeWindowController"];
}

- (void)windowDidLoad;
{
  self.window.title = NSLocalizedString(@"MAIN_WINDOW_TITLE", nil);
  self.openGuidesButton.title = NSLocalizedString(@"MAIN_WINDOW_OPEN_GUIDES_BUTTON_TITLE", nil);
  self.openSearchButton.title = NSLocalizedString(@"MAIN_WINDOW_OPEN_SEARCH_BUTTON_TITLE", nil);
  self.openChangelogButton.title = NSLocalizedString(@"MAIN_WINDOW_CHANGELOG_BUTTON_TITLE", nil);
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
