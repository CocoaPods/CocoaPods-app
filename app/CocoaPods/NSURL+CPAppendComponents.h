//
//  NSURL+CPAppendComponents.h
//  CocoaPods
//
//  Created by William Kent on 9/10/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CPAppendComponents)

- (nonnull NSURL *)URLByAppendingPathComponents:(nonnull NSArray<NSString *> *)pathComponents;

@end
