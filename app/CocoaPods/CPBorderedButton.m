#import "CPBorderedButton.h"
#import "NSAttributedString+Helpers.h"

@implementation CPBorderedButton

-(void)awakeFromNib
{
  [super awakeFromNib];

  NSButtonCell * cell = (id)[self cell];
  cell.imageDimsWhenDisabled = false;
  [self setTitle:self.title];
}

@end

@interface CPBorderedButtonCell()
@property (strong) NSColor *textColor;

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

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
  [super highlight:flag withFrame:cellFrame inView:controlView];
  self.textColor = flag ? [NSColor colorWithCalibratedRed:0.227 green:0.463 blue:0.733 alpha:1] : [NSColor colorWithCalibratedWhite:1 alpha:1];
  
  // Re-renders the text via the function below
  self.title = self.title;
}

- (void)setTitle:(NSString *)title
{
  self.attributedTitle = [NSAttributedString string:title
                                              color:self.textColor ?: [NSColor colorWithCalibratedWhite:1 alpha:1]
                                               font:self.font ?: [NSFont labelFontOfSize:12]
                                          alignment:NSTextAlignmentCenter];
}

@end