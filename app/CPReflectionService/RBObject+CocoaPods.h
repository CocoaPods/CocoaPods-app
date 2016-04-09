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
- (NSArray<RBGemSpecification *> * _Nonnull)installed_specifications_for_prefix:(NSString * _Nonnull)prefix;
- (RBGemSpecification * _Nonnull)specification:(NSString * _Nonnull)pluginPath;
@end

// Defined in RBObject+CocoaPods.rb
@interface RBApp : RBObject
- (void)require_gems;
- (NSDictionary * _Nonnull)analyze_podfile:(RBPodfile * _Nonnull)contents :(NSString * _Nonnull)installationRoot;
- (NSArray<NSString *> * _Nullable)all_pods;
- (NSString * _Nullable)lockfile_version:(RBPathname * _Nonnull)path;
- (NSNumber * _Nonnull)compare_versions:(NSString * _Nonnull)version1 :(NSString * _Nonnull)version2;
@end

