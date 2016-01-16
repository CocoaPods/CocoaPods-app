#import "NSAttributedString+Helpers.h"

@implementation NSAttributedString(Helpers)

+ (NSAttributedString *)string:(NSString *)string color:(NSColor *)color font:(NSFont *)font alignment:(NSTextAlignment)alignment
{
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.alignment = alignment;

  return [[NSAttributedString alloc] initWithString:string attributes: @{
    NSForegroundColorAttributeName: color,
    NSFontAttributeName: font,
    NSParagraphStyleAttributeName: style
  }];
}

@end
