#import "CPHomeMenuTableCellView.h"

@implementation CPHomeMenuTableCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
  [super setBackgroundStyle:backgroundStyle];

  BOOL highlighted = backgroundStyle == NSBackgroundStyleLight;
  self.subtitleTextField.textColor = highlighted ? [NSColor darkGrayColor] : [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
}

@end
