//
//  CPHomeWindowController.m
//  CocoaPods
//
//  Created by William Kent on 9/10/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import "CPHomeWindowController.h"

@interface CPHomeWindowController ()

@end

@implementation CPHomeWindowController

- (id)init;
{
  return [self initWithWindowNibName:@"CPHomeWindowController"];
}

- (void)windowDidLoad;
{
  self.window.excludedFromWindowsMenu = YES;
}

@end
