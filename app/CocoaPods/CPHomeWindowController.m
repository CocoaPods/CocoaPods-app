//
//  CPHomeWindowController.m
//  CocoaPods
//
//  Created by William Kent on 9/10/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import "CPHomeWindowController.h"
#import <INAppStoreWindow/INAppStoreWindow.h>

@interface CPHomeWindowController ()

@property IBOutlet NSView *titleBarView;

@end

@implementation CPHomeWindowController

- (void)windowDidLoad {
  [super windowDidLoad];

  INAppStoreWindow *window = (INAppStoreWindow *)self.window;
  window.titleBarHeight = self.titleBarView.frame.size.height;
  [window.titleBarView addSubview:self.titleBarView];
}

@end
