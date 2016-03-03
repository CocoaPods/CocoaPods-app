#import <Foundation/Foundation.h>
#import "CPRubyErrors.h"

@protocol CPReflectionServiceProtocol

- (void)XcodeIntegrationInformationFromPodfile:(NSString * _Nonnull)contents
                              installationRoot:(NSString * _Nonnull)installationRoot
                                     withReply:(void (^ _Nonnull)(NSDictionary * _Nullable information, NSError * _Nullable error))reply;

- (void)installedPlugins:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;

- (void)pluginsFromPodfile:(NSString * _Nonnull)contents
                 withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;

- (void)versionFromLockfile:(NSString * _Nonnull)path
                  withReply:(void (^ _Nonnull)(NSString * _Nullable version, NSError * _Nullable error))reply;

- (void)allPods:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable pods, NSError * _Nullable error))reply;

@end
