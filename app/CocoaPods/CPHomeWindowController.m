#import "CPHomeWindowController.h"
#import "CPRecentDocumentsController.h"
#import "CocoaPods-Swift.h"
#import "CPCLIToolInstallationController.h"

NSString * const kCPCLIToolSuggestedDestination = @"/usr/local/bin/pod";

@interface CPHomeWindowController ()

@property (strong) IBOutlet CPRecentDocumentsController *recentDocumentsController;

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *cocoapodsVersionTextField;
@property (weak) IBOutlet NSButton *openGuidesButton;
@property (weak) IBOutlet NSButton *openSearchButton;
@property (weak) IBOutlet NSButton *openChangelogButton;

@property (strong) IBOutlet NSView *installCommandLineToolsView;
@property (weak) IBOutlet NSLayoutConstraint *commandLineToolsHeightConstraint;

@property (strong) CPCLIToolInstallationController *cliToolController;
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

  self.cliToolController = [self createCLIToolInstallationController];
  if ([self.cliToolController shouldInstallBinstubIfNecessary]) {
    [self addCLIInstallerMessageAnimated:YES];
  }
}

- (void)didDoubleTapOnRecentItem:(NSTableView *)sender;
{
  NSInteger row = [sender selectedRow];
  CPHomeWindowDocumentEntry *item = self.recentDocumentsController.recentDocuments[row];

  NSDocumentController *controller = [NSDocumentController sharedDocumentController];
  [controller openDocumentWithContentsOfURL:item.podfileURL display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
    [self.window orderOut:self];
  }];
}

/// Takes the installCommandLineToolsView and pulls it out of the nib
/// adding it into the contentview of the window, then animates it down
/// to peak into the message.

static CGFloat CPCommandLineAlertHeight = 68;

- (void)addCLIInstallerMessageAnimated:(BOOL)animate;
{
  NSView *content = self.window.contentView;
  self.commandLineToolsHeightConstraint.constant = 2;
  [content addSubview:self.installCommandLineToolsView];

  NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.installCommandLineToolsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:content attribute:NSLayoutAttributeTop multiplier:1 constant:20];
  [content addConstraint:topConstraint];

  id constraint = animate ? self.commandLineToolsHeightConstraint.animator : self.commandLineToolsHeightConstraint;
  [constraint setConstant:CPCommandLineAlertHeight];
}

/// Expands the message to the full height of the home screen window

- (IBAction)showFullCLIInstallerMessageAnimated:(NSButton *)sender;
{

  if ([sender.title isEqualToString:@"Close"]) {
    [self.commandLineToolsHeightConstraint.animator setConstant:CPCommandLineAlertHeight];
    [sender setTitle:@"Help"];

  } else {
    NSView *content = self.window.contentView;
    [self.commandLineToolsHeightConstraint.animator setConstant:CGRectGetHeight(content.bounds)];
    [sender setTitle:@"Close"];

  }
}

/// Installs the bin stub

- (IBAction)installBinstub:(id)sender;
{
  if ([self.cliToolController installBinstub]) {
    // Hide the alert
    [self.commandLineToolsHeightConstraint.animator setConstant:0];

  } else if(self.cliToolController.errorMessage) {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = self.cliToolController.errorMessage;
    [alert runModal];
  }
}

/// Lets a user change the directory, the UI
/// showing the path uses bindings which are changed
/// when a new path is set.

- (IBAction)changeInstallationPath:(id)sender;
{
  [self.cliToolController runModalDestinationChangeSavePanel];
}

/// This _does_ work, if you're in a dev build though, it's set
/// to delete this key on launch in CPAppDelegate

- (IBAction)setDontShowTheCLIWarningAgain:(NSButton *)sender;
{
  [[NSUserDefaults standardUserDefaults] setBool:sender.state == NSOnState forKey:kCPDoNotRequestCLIToolInstallationAgainKey];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (CPCLIToolInstallationController *)createCLIToolInstallationController;
{
  NSURL *destinationURL = [NSURL fileURLWithPath:kCPCLIToolSuggestedDestination];
  return [CPCLIToolInstallationController controllerWithSuggestedDestinationURL:destinationURL];
}

@end
