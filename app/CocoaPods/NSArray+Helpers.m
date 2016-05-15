#import "NSArray+Helpers.h"

@implementation NSArray(Helpers)

- (NSArray *)map:(id (^)(id obj))block
{
  NSMutableArray *new = [NSMutableArray array];
  for(id obj in self) {
    id newObj = block(obj);
    [new addObject: newObj ? newObj : [NSNull null]];
  }
  return new;
}

- (NSArray *)select:(BOOL (^)(id obj))test
{
  NSMutableArray *new = [NSMutableArray array];
  for(id obj in self) {
    if (test(obj)) {
      [new addObject: obj];
    }
  }
  return new;
}

- (NSArray *)reject:(BOOL (^)(id obj))test
{
  return [self select:^ BOOL (id obj) {
    return !test(obj);
  }];
}

@end
