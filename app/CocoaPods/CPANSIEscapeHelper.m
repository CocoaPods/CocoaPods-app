//
//  CPANSIEscapeHelper.m
//  CocoaPods
//
//  Created by Michael Vilabrera on 9/5/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

#import "CPANSIEscapeHelper.h"
#import <Fragaria/MGSFragariaFramework.h>

@implementation CPANSIEscapeHelper

- (instancetype) init {
  self = [super init];
  if (!self) {
    return  nil;
  }
  
  
  NSData *fontData = [[NSUserDefaults standardUserDefaults] valueForKey:MGSFragariaPrefsTextFont];
  NSFont *font = [NSUnarchiver unarchiveObjectWithData:fontData];
    
  self.font = font;
  
  self.ansiColors[@(AMR_SGRCodeFgBlack)] = [NSColor colorWithCalibratedRed:0.180f green:0.000f blue:0.008f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgRed)] = [NSColor colorWithCalibratedRed:0.682f green:0.000f blue:0.000f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgGreen)] = [NSColor colorWithCalibratedRed:0.161f green:0.608f blue:0.086f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgYellow)] = [NSColor colorWithCalibratedRed:0.659f green:0.675f blue:0.055f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBlue)] = [NSColor colorWithCalibratedRed:0.227f green:0.463f blue:0.733f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgMagenta)] = [NSColor colorWithCalibratedRed:0.427f green:0.404f blue:0.698f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgCyan)] = [NSColor colorWithCalibratedRed:0.239f green:0.616f blue:0.753f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgWhite)] = [NSColor colorWithCalibratedRed:0.812f green:0.812f blue:0.812f alpha:1.00f];
  
  self.ansiColors[@(AMR_SGRCodeFgBrightBlack)] = [NSColor colorWithCalibratedRed:0.012f green:0.012f blue:0.012f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBrightRed)] = [NSColor colorWithCalibratedRed:0.980f green:0.000f blue:0.000f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBrightGreen)] = [NSColor colorWithCalibratedRed:0.192f green:0.745f blue:0.098f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBrightYellow)] = [NSColor colorWithCalibratedRed:0.659f green:0.675f blue:0.055f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBrightBlue)] = [NSColor colorWithCalibratedRed:0.282f green:0.576f blue:0.902f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBrightMagenta)] = [NSColor colorWithCalibratedRed:0.553f green:0.522f blue:0.898f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBrightCyan)] = [NSColor colorWithCalibratedRed:0.282f green:0.729f blue:0.902f alpha:1.00f];
  self.ansiColors[@(AMR_SGRCodeFgBrightWhite)] = [NSColor colorWithCalibratedRed:0.773f green:0.773f blue:0.773f alpha:1.00f];
    
  return self;
}

@end
