#import <Foundation/Foundation.h>
#import <RubyCocoa/RBObject.h>

id _Nonnull RBObjectFromString(NSString * _Nonnull source);

@interface RBObject (CocoaPods)
+ (void)performBlock:(void (^ _Nonnull)(void))block;
+ (void)performBlockAndWait:(void (^ _Nonnull)(void))block;
@end

#pragma mark - CocoaPods classes

@interface CPPodfile : RBObject
+ (instancetype _Nonnull)from_ruby:(NSString * _Nonnull)path :(NSString * _Nullable)contents;
- (NSDictionary<NSString *, NSDictionary *> * _Nonnull)plugins;
@end