#import <Cocoa/Cocoa.h>

@class MGSFragariaView, CPPodfileEditorViewController;

@interface CPPodfileReflection : NSObject <NSTextViewDelegate>

- (instancetype)initWithPodfileEditorVC:(CPPodfileEditorViewController *)editor fragariaEditor:(MGSFragariaView *)fragaria;

@end
