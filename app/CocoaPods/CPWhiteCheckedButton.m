#import "CPWhiteCheckedButton.h"

@implementation CPWhiteCheckedButton

- (void)awakeFromNib
{
  [super awakeFromNib];

  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.alignment = NSTextAlignmentCenter;

  self.attributedTitle = [[NSAttributedString alloc] initWithString:self.title attributes: @{
    NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:1 alpha:1],
    NSFontAttributeName: self.font ?: [NSFont labelFontOfSize:12],
    NSParagraphStyleAttributeName: style
  }];
}

@end
