//
//  CPPodfileSyntaxChecker.h
//  CocoaPods
//
//  Created by Orta on 11/27/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MGSFragariaView, CPPodfileEditorViewController;

@interface CPPodfileReflection : NSObject <NSTextViewDelegate>

- (instancetype)initWithPodfileEditorVC:(CPPodfileEditorViewController *)editor fragariaEditor:(MGSFragariaView *)fragaria;

@end
