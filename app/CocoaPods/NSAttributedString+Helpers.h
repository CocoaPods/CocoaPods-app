@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString(Helpers)

+ (NSAttributedString *)string:(NSString *)string color:(NSColor *)color font:(NSFont *)font alignment:(NSTextAlignment)alignment;

@end

NS_ASSUME_NONNULL_END