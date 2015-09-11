//
//  NSURL+CPAppendComponents.m
//  CocoaPods
//
//  Created by William Kent on 9/10/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import "NSURL+CPAppendComponents.h"

@implementation NSURL (CPAppendComponents)

- (nonnull NSURL *)URLByAppendingPathComponents:(nonnull NSArray<NSString *> *)pathComponents;
{
  NSURL *result = [self copy];

  for (NSString *component in pathComponents) {
    result = [result URLByAppendingPathComponent:component];
  }

  return result;
}

@end
