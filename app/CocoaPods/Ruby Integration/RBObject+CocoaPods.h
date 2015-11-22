#import <Foundation/Foundation.h>
#import <RubyCocoa/RBObject.h>

@interface RBObject (CocoaPods)
+ (void)performBlock:(void (^ _Nonnull)(void))block;
+ (void)performBlockAndWait:(void (^ _Nonnull)(void))block;
@end
