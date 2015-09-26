//
//  SMLTextView+CocoaPods.m
//  CocoaPods
//
//  Created by Orta Therox on 05/09/2015.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

#import <Fragaria/MGSFragariaFramework.h>
#import <objc/runtime.h>

// Hack SMLTextView to also consider the leading colon when completing words, which are all the
// symbols that we support.
//
@implementation SMLTextView (CPIncludeLeadingColonsInCompletions)

+ (void)load;
{
  Method m1 = class_getInstanceMethod(self, @selector(rangeForUserCompletion));
  Method m2 = class_getInstanceMethod(self, @selector(CP_rangeForUserCompletion));
  method_exchangeImplementations(m1, m2);
}

-(NSRange)CP_rangeForUserCompletion;
{
  NSRange range = [self CP_rangeForUserCompletion];
  if (range.location != NSNotFound && range.location > 0
      && [self.string characterAtIndex:range.location -1] == ':') {
    
    range = NSMakeRange(range.location -1, range.length +1);
  }
  return range;
}

@end
