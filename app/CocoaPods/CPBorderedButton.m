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

@implementation CPBorderedButtonCell

/// Based on this gist: https://gist.github.com/marteinn/fa9301ad349b755da2e6

- (NSRect)titleRectForBounds:(NSRect)rect
{
  NSRect titleFrame = [super titleRectForBounds:rect];
  NSSize titleSize = [[self attributedStringValue] size];

  titleFrame.origin.y = roundf(rect.origin.y-(rect.size.height-titleSize.height)* 0.5) + 1;

  return titleFrame;
}

@end