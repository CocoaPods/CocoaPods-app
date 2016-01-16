#import "CPRecentDocumentsController.h"
#import "NSColor+CPColors.h"
#import "NSArray+Helpers.h"
#import "CPHomeWindowDocumentEntry.h"
#import "NSAttributedString+Helpers.h"

@implementation CPRecentDocumentsController

- (void)awakeFromNib
{
  [super awakeFromNib];

  NSString *title = NSLocalizedString(@"MAIN_WINDOW_OPEN_DOCUMENT_BUTTON_TITLE", nil);
  NSAttributedString *attrTitle = [NSAttributedString string:title color:[NSColor ansiMutedWhite] font:[NSFont labelFontOfSize:13] alignment:NSTextAlignmentCenter];

  [self.openDocumentButton setAttributedTitle:attrTitle];

  attrTitle = [NSAttributedString string:title color:[NSColor ansiBrightWhite] font:[NSFont labelFontOfSize:13] alignment:NSTextAlignmentCenter];

  [self.openDocumentButton setAttributedAlternateTitle:attrTitle];
  
  [self prepareData];
}

- (NSArray<CPHomeWindowDocumentEntry *> *)recentDocuments
{
  NSDocumentController *controller = [NSDocumentController sharedDocumentController];
  return [controller.recentDocumentURLs map:^id(id url) {
    return [CPHomeWindowDocumentEntry documentEntryWithURL:url];
  }];
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
//  [self setupRecentDocuments];
  [self prepareData];
  [self.documentsTableView reloadData];
}

@end
