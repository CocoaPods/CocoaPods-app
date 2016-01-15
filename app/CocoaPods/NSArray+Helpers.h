#import <Foundation/Foundation.h>

@interface NSArray(Helpers)

/// Converts all properties of one object to another
- (NSArray *)map: (id (^)(id obj))block;

@end
