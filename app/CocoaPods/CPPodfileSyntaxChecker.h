//
//  CPPodfileSyntaxChecker.h
//  CocoaPods
//
//  Created by Orta on 11/27/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MGSFragariaView, CPPodfileEditorViewController;

/// Handles keeping on top of the syntax for the Podfile
/// at runtime. Note: Comes with a side-effect of setting the
/// plugins array on the

@interface CPPodfileSyntaxChecker : NSObject <NSTextViewDelegate>

- (instancetype)initWithPodfileEditorVC:(CPPodfileEditorViewController *)editor fragariaEditor:(MGSFragariaView *)fragaria;

@end
