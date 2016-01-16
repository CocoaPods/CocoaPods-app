#import "CPWhiteCheckedButton.h"
#import "NSAttributedString+Helpers.h"

@implementation CPWhiteCheckedButton

- (void)awakeFromNib
{
  [super awakeFromNib];

  self.attributedTitle = [NSAttributedString string:self.title color:[NSColor colorWithWhite:1 alpha:1] font:[NSFont labelFontOfSize:12] alignment:NSTextAlignmentCenter];
}

@end
