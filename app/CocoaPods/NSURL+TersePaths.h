#import <Foundation/Foundation.h>

@interface NSURL(TersePaths)

/// Takes an NSURL for a file, and returns a
/// tilde prefixed string representing it.

- (NSString *)tersePath;

@end
