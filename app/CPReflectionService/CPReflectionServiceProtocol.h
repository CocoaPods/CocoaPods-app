#import <Foundation/Foundation.h>
#import "CPRubyErrors.h"

@protocol CPReflectionServiceProtocol

- (void)XcodeIntegrationInformationFromPodfile:(NSString * _Nonnull)contents
                              installationRoot:(NSString * _Nonnull)installationRoot
                                     withReply:(void (^ _Nonnull)(NSDictionary * _Nullable information, NSError * _Nullable error))reply;

- (void)installedPlugins:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;

- (void)pluginsFromPodfile:(NSString * _Nonnull)contents
                 withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;

- (void)allCocoaPodsSources:(void (^ _Nonnull)(NSDictionary<NSString * , NSString * > * _Nonnull sources, NSError * _Nullable error))reply;

- (void)sourcesFromPodfile:(NSString * _Nonnull)contents
                 withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable sources, NSError * _Nullable error))reply;

- (void)versionFromLockfile:(NSString * _Nonnull)path
                  withReply:(void (^ _Nonnull)(NSString * _Nullable version, NSError * _Nullable error))reply;

- (void)appVersion:(NSString * _Nonnull)appVersion
isOlderThanLockfileVersion:(NSString * _Nonnull)lockfileVersion
         withReply:(void (^ _Nonnull)(NSNumber * _Nullable older, NSError * _Nullable error))reply;

- (void)allPods:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable pods, NSError * _Nullable error))reply;

- (void)versionsForPodNamed:(NSString * _Nonnull)podName withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable versions, NSError * _Nullable error))reply;

@end
