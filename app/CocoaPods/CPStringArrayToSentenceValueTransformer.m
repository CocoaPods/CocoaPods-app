#import "CPStringArrayToSentenceValueTransformer.h"

@implementation CPStringArrayToSentenceValueTransformer

+ (void)load {
  @autoreleasepool {
    NSString * const ClassNameTransformerName = @"CPStringArrayToSentenceValueTransformer";
    [NSValueTransformer setValueTransformer:[[CPStringArrayToSentenceValueTransformer alloc] init] forName:ClassNameTransformerName];
  }
}

+ (Class)transformedValueClass
{
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
  return NO;
}

- (id)transformedValue:(NSArray *)value
{
  if (!value || value.count == 0) { return nil; }
  if (value && value.count == 1) { return value.firstObject; }

  NSMutableArray *commas = [value mutableCopy];
  [commas removeLastObject];

  return [[commas componentsJoinedByString:@", "] stringByAppendingFormat:@" & %@", value.lastObject];
}

@end
