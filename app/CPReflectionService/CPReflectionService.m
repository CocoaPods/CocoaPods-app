#import "CPReflectionService.h"
#import "RBObject+CocoaPods.h"
#import "NSArray+Helpers.h"

@implementation CPReflectionService

- (void)pluginsFromPodfile:(NSString * _Nonnull)contents
                 withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;
{
  [RBObject performBlock:^{
    // Use just `Podfile` as the path so that we can make assumptions about error messages
    // and easily remove the path being mentioned.
    RBPathname *pathname = [RBObjectFromString(@"Pathname") new:@"Podfile"];

    RBPodfile *podfile = [RBObjectFromString(@"Pod::Podfile") from_ruby:pathname :contents];
    NSArray *plugins = podfile.plugins.allKeys;
    reply(plugins, nil);

  } error:^(NSError * _Nonnull error) {
    reply(nil, error);
  }];
}

- (void)versionFromLockfile:(NSString * _Nonnull)path
                  withReply:(void (^ _Nonnull)(NSString * _Nullable, NSError * _Nullable))reply;
{
  [RBObject performBlock:^{
    RBPathname *rubyPath = [RBObjectFromString(@"Pathname") new:path];
    reply([RBObjectFromString(@"Pod::App") lockfile_version:rubyPath], nil);
  } error:^(NSError * _Nonnull error) {
    reply(nil, error);
  }];
}

- (void)appVersion:(NSString * _Nonnull)appVersion isOlderThanLockfileVersion:(NSString * _Nonnull)lockfileVersion withReply:(void (^)(NSNumber * _Nullable, NSError * _Nullable))reply;
{
  [RBObject performBlock:^{
    NSNumber *comparison = [RBObjectFromString(@"Pod::App") compare_versions:appVersion :lockfileVersion];
    NSNumber *older = [comparison integerValue] < 0 ? @1 : @0;
    reply(older, nil);
  } error:^(NSError * _Nonnull error) {
    reply(nil, error);
  }];
}

- (void)installedPlugins:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;
{
  [RBObject performBlock:^{
    RBPluginManager *pluginManager = RBObjectFromString(@"CLAide::Command::PluginManager");
    NSArray *specs = [pluginManager installed_specifications_for_prefix:@"cocoapods"];

    reply([specs map:^id(id spec) {
      return [spec name];
    }], nil);

  } error:^(NSError * _Nonnull error) {
    reply(nil, error);
  }];
}

- (void)XcodeIntegrationInformationFromPodfile:(NSString * _Nonnull)contents
                              installationRoot:(NSString * _Nonnull)installationRoot
                                     withReply:(void (^ _Nonnull)(NSDictionary * _Nullable information, NSError * _Nullable error))reply;
{
  [RBObject performBlock:^{
    RBPathname *pathname = [RBObjectFromString(@"Pathname") new:@"Podfile"];
    RBPodfile *podfile = [RBObjectFromString(@"Pod::Podfile") from_ruby:pathname :contents];
    NSDictionary *info = [RBObjectFromString(@"Pod::App") analyze_podfile:podfile :[RBObjectFromString(@"Pathname") new:installationRoot]];
    reply(info, nil);

  } error:^(NSError * _Nonnull error) {
    reply(nil, error);
  }];

}

- (void)allPods:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable pods, NSError * _Nullable error))reply
{
  [RBObject performBlock:^{
    reply([RBObjectFromString(@"Pod::App") all_pods], nil);
  } error:^(NSError * _Nonnull error) {
    reply(nil, error);
  }];
}

@end
