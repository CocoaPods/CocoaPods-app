#import "CPRecentDocumentsController.h"
#import "NSColor+CPColors.h"
#import "NSArray+Helpers.h"
#import "CPHomeWindowDocumentEntry.h"

@implementation CPRecentDocumentsController

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  NSMutableAttributedString *attrTitle =
  [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"MAIN_WINDOW_OPEN_DOCUMENT_BUTTON_TITLE", nil)];
  NSUInteger len = [attrTitle length];
  NSRange range = NSMakeRange(0, len);
  [attrTitle addAttribute:NSForegroundColorAttributeName value:[NSColor ansiMutedWhite] range:range];
  [attrTitle addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:13.0] range:range];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  [attrTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
  [attrTitle fixAttributesInRange:range];
  [self.openDocumentButton setAttributedTitle:attrTitle];
  [attrTitle addAttribute:NSForegroundColorAttributeName value:[NSColor ansiBrightWhite] range:range];
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


@end
