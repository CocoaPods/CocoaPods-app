#import <Foundation/Foundation.h>
#import <RubyCocoa/RBObject.h>

id _Nonnull RBObjectFromString(NSString * _Nonnull source);

@interface RBObject (CocoaPods)
+ (void)performBlock:(void (^ _Nonnull)(void))block;
+ (void)performBlockAndWait:(void (^ _Nonnull)(void))block;
@end

#pragma mark - Ruby class interfaces

@interface RBObject (Ruby)
- (id _Nullable)send:(NSString * _Nonnull)methodName;
@end

@interface RBPathname : RBObject
@end

@interface RBPodfile : RBObject
+ (instancetype _Nonnull)from_ruby:(RBPathname * _Nonnull)path :(NSString * _Nullable)contents;
- (NSDictionary<NSString *, NSDictionary *> * _Nonnull)plugins;
@end