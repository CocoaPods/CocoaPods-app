#import <Foundation/Foundation.h>
#import <RubyCocoa/RBObject.h>

NSError * _Nonnull CPErrorFromException(NSException * _Nonnull exception, NSString * _Nullable message);

#pragma mark - Ruby integration

id _Nonnull RBObjectFromString(NSString * _Nonnull source);

typedef void (^RBObjectTaskBlock)(void);
typedef void (^RBObjectErrorBlock)(NSError * _Nonnull error);

@interface RBObject (CocoaPods)
+ (void)performBlock:(RBObjectTaskBlock _Nonnull)taskBlock error:(RBObjectErrorBlock _Nonnull)errorBlock;
+ (void)performBlockAndWait:(RBObjectTaskBlock _Nonnull)taskBlock error:(RBObjectErrorBlock _Nonnull)errorBlock;
@end

#pragma mark - Ruby class interfaces

@interface RBObject (Ruby)
+ (instancetype _Nonnull)new:(id _Nonnull)arg __attribute__((ns_returns_autoreleased));
- (id _Nullable)send:(NSString * _Nonnull)methodName;
@end

@interface RBException : RBObject
- (RBException * _Nonnull)cause;
- (NSString * _Nonnull)message;
@end

@interface RBPathname : RBObject
@end

@interface RBPodfile : RBObject
+ (instancetype _Nonnull)from_ruby:(RBPathname * _Nonnull)path :(NSString * _Nullable)contents;
- (NSDictionary<NSString *, NSDictionary *> * _Nonnull)plugins;
@end

@interface RBGemSpecification : RBObject
- (NSString * _Nonnull)name;
@end

@interface RBPluginManager : RBObject
// TODO This has been changed in CLAide master and should be updated on the next release!
// https://github.com/CocoaPods/CLAide/pull/54
- (NSArray<NSString *> * _Nonnull)plugin_load_paths:(NSString * _Nonnull)prefix;
- (RBGemSpecification * _Nonnull)specification:(NSString * _Nonnull)pluginPath;
@end