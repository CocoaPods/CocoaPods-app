//
//  CPANSIEscapeHelper.m
//  CocoaPods
//
//  Created by Michael Vilabrera on 9/5/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

#import "CPANSIEscapeHelper.h"
#import <Fragaria/Fragaria.h>

@implementation CPANSIEscapeHelper

- (instancetype) init {
  self = [super init];
  if (!self) {
    return  nil;
  }
  
  
  NSData *fontData = [[MGSFragariaView defaultsDictionary] valueForKey:MGSFragariaDefaultsTextFont];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:fontData];
    
  self.font = font;
  
  self.ansiColors[@(AMR_SGRCodeFgBlack)] = [NSColor colorWithCalibratedRed:0.180 green:0.000 blue:0.008 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgRed)] = [NSColor colorWithCalibratedRed:0.682 green:0.000 blue:0.000 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgGreen)] = [NSColor colorWithCalibratedRed:0.161 green:0.608 blue:0.086 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgYellow)] = [NSColor colorWithCalibratedRed:0.659 green:0.675 blue:0.055 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBlue)] = [NSColor colorWithCalibratedRed:0.227 green:0.463 blue:0.733 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgMagenta)] = [NSColor colorWithCalibratedRed:0.427 green:0.404 blue:0.698 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgCyan)] = [NSColor colorWithCalibratedRed:0.239 green:0.616 blue:0.753 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgWhite)] = [NSColor colorWithCalibratedRed:0.812 green:0.812 blue:0.812 alpha:1.00];
  
  self.ansiColors[@(AMR_SGRCodeFgBrightBlack)] = [NSColor colorWithCalibratedRed:0.012 green:0.012 blue:0.012 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBrightRed)] = [NSColor colorWithCalibratedRed:0.980 green:0.000 blue:0.000 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBrightGreen)] = [NSColor colorWithCalibratedRed:0.192 green:0.745 blue:0.098 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBrightYellow)] = [NSColor colorWithCalibratedRed:0.659 green:0.675 blue:0.055 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBrightBlue)] = [NSColor colorWithCalibratedRed:0.282 green:0.576 blue:0.902 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBrightMagenta)] = [NSColor colorWithCalibratedRed:0.553 green:0.522 blue:0.898 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBrightCyan)] = [NSColor colorWithCalibratedRed:0.282 green:0.729 blue:0.902 alpha:1.00];
  self.ansiColors[@(AMR_SGRCodeFgBrightWhite)] = [NSColor colorWithCalibratedRed:0.773 green:0.773 blue:0.773 alpha:1.00];
    
  return self;
}

@end
