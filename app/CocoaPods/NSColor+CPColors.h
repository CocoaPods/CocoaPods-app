//
//  UIColor+CPColors.h
//  CocoaPods
//
//  Created by Maxim Cramer on 15/01/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@interface NSColor(CPColors)

// *** Default color palette ***

+ (NSColor *)CPDarkRedColor;
+ (NSColor *)CPBrightRedColor;
+ (NSColor *)CPLightGrayColor;
+ (NSColor *)CPGrayColor;
+ (NSColor *)CPDarkColor;

// *** ANSI color palette ***

+ (NSColor *)ansiMutedWhite;
+ (NSColor *)ansiBrightWhite;


@end
