//
//  UIColor+CPColors.m
//  CocoaPods
//
//  Created by Maxim Cramer on 15/01/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "NSColor+CPColors.h"

@implementation NSColor (CPColors)

- (NSColor *)DarkRedColor
{
  return [NSColor colorWithRed:190.0/255.0 green:25.0/255.0 blue:0.0/255.0 alpha:1.0]
}

- (NSColor *)BrightRedColor
{
  return [NSColor colorWithRed:254.0/255.0 green:37.0/255.0 blue:0.0/255.0 alpha:1.0]
}

- (NSColor *)LightGrayColor
{
   return [NSColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]
}

- (NSColor *)GrayColor
{
    return [NSColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1.0]
}

- (NSColor *)DarkColor
{
    return [NSColor colorWithRed:56.0/255.0 green:2.0/255.0 blue:0.0/255.0 alpha:1.0]
}

- (NSColor *)ansiMutedWhite;
{
  return [NSColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0]
}

- (NSColor *)ansiBrightWhite;
{
  return [NSColor colorWithRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0]
}


@end
