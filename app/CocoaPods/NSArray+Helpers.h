#import <Foundation/Foundation.h>

@interface NSArray(Helpers)

/// Returns a new array by transforming all elements using block
- (NSArray *)map: (id (^)(id obj))block;

/// Returns a new array including only the elements that pass the test
- (NSArray *)select:(BOOL (^)(id obj))test;

/// Returns a new array excluding the elements that pass the test
- (NSArray *)reject: (BOOL (^)(id obj))test;

@end
