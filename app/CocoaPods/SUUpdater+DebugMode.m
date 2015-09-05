//
//  SUUpdater+DebugMode.m
//  CocoaPods
//
//  Created by Orta Therox on 05/09/2015.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

#import <Sparkle/Sparkle.h>
#import <objc/runtime.h>

// Hack Sparkle to not show _super annoying_ DSA warning
// when you don't have developer signing set up
//
// https://github.com/sparkle-project/Sparkle/blob/master/Sparkle/SUUpdater.m#L110
//

#ifdef DEBUG

@implementation SUUpdater (CPIncludeLeadingColonsInCompletions)

+ (void)load;
{
  Method m1 = class_getInstanceMethod(self, @selector(initForBundle:));
  Method m2 = class_getInstanceMethod(self, @selector(CP_initForBundle:));
  method_exchangeImplementations(m1, m2);
}

// Basically don't do any Sparkle work at all.

- (instancetype)CP_initForBundle:(NSBundle *)bundle
{
  return [super init];
}

@end

#endif
