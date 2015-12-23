#import "CPBorderedButton.h"

@implementation CPBorderedButton

-(void)awakeFromNib
{
  [super awakeFromNib];

  NSButtonCell * cell = (id)[self cell];
  cell.imageDimsWhenDisabled = false;
  [self setTitle:self.title];
}

- (void)setTitle:(NSString *)title
{
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.alignment = NSTextAlignmentCenter;

  self.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes: @{
     NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:1 alpha:1],
     NSFontAttributeName: self.font ?: [NSFont labelFontOfSize:12],
     NSParagraphStyleAttributeName: style
   }];
}

@end
