#import <Foundation/Foundation.h>
#import "CPRubyErrors.h"

@protocol CPReflectionServiceProtocol

- (void)getXcodeIntegrationInformation:(void (^ _Nonnull)(NSDictionary * _Nullable information, NSError * _Nullable error))reply;

- (void)installedPlugins:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;

- (void)pluginsFromPodfile:(NSString * _Nonnull)contents
                 withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;

@end
