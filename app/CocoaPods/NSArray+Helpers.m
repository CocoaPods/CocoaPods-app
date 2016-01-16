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

@end
