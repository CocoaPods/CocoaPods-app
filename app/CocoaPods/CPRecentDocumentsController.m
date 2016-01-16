#import "CPRecentDocumentsController.h"
#import "NSURL+TersePaths.h"
#import "NSColor+CPColors.h"
#import "NSAttributedString+Helpers.h"

@implementation CPHomeWindowDocumentEntry

- (instancetype)copyWithZone:(NSZone *)zone
{
  CPHomeWindowDocumentEntry *copy = [[[self class] allocWithZone:zone] init];
  if (copy) {
    [copy setName:[self.name copyWithZone:zone]];
    [copy setPodfileURL:[self.podfileURL copyWithZone:zone]];
    [copy setImage:[self.image copyWithZone:zone]];
    [copy setFileDescription:[self.fileDescription copyWithZone:zone]];
  }

  return copy;
}

@end

@implementation CPRecentDocumentsController

- (void)awakeFromNib
{
  [super awakeFromNib];

  NSString *title = NSLocalizedString(@"MAIN_WINDOW_OPEN_DOCUMENT_BUTTON_TITLE", nil);
  NSAttributedString *attrTitle = [NSAttributedString string:title color:[NSColor ansiMutedWhite] font:[NSFont labelFontOfSize:13] alignment:NSTextAlignmentCenter];

  [self.openDocumentButton setAttributedTitle:attrTitle];

  attrTitle = [NSAttributedString string:title color:[NSColor ansiBrightWhite] font:[NSFont labelFontOfSize:13] alignment:NSTextAlignmentCenter];

  [self.openDocumentButton setAttributedAlternateTitle:attrTitle];
  
  [self setupRecentDocuments];
  [self prepareData];
}

- (void)setupRecentDocuments
{
  NSDocumentController *controller = [NSDocumentController sharedDocumentController];
  NSMutableArray *documents = [NSMutableArray arrayWithCapacity:controller.recentDocumentURLs.count];
  for (NSURL *url in controller.recentDocumentURLs) {
    [documents addObject:[self projectDetailsAtURL:url]];
  }

  self.recentDocuments = documents;
}

- (void)prepareData
{
  if ([self.recentDocuments count] > 0) {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:0];
    [self.documentsTableView selectRowIndexes:indexes byExtendingSelection:NO];
    self.documentsTableView.hidden = NO;
    self.openDocumentButton.hidden = YES;
  } else {
    self.documentsTableView.hidden = YES;
    self.openDocumentButton.hidden = NO;
  }
}

- (void)refreshRecentDocuments
{
  [self setupRecentDocuments];
  [self prepareData];
  [self.documentsTableView reloadData];
}

- (CPHomeWindowDocumentEntry *)projectDetailsAtURL:(NSURL *)url
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *dirFiles = [fileManager contentsOfDirectoryAtURL:[url URLByDeletingLastPathComponent] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];

  NSPredicate *workspacePredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'xcworkspace'"];
  NSPredicate *projectPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'xcodeproj'"];
  NSURL *workspaceURL = [[dirFiles filteredArrayUsingPredicate:workspacePredicate] firstObject];
  NSURL *projectURL = [[dirFiles filteredArrayUsingPredicate:projectPredicate] firstObject];
  NSURL *bestURL = workspaceURL ?: projectURL ?: url;

  CPHomeWindowDocumentEntry *document = [CPHomeWindowDocumentEntry new];
  document.name = [bestURL lastPathComponent];
  document.image = [NSImage imageNamed:@"Podfile-icon"];
  document.podfileURL = url;
  document.fileDescription = workspaceURL? @"Podfile" : [bestURL tersePath];
  return document;
}

@end
