#import "CPReflectionService.h"
#import "RBObject+CocoaPods.h"

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

- (void)installedPlugins:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;
{
  [RBObject performBlock:^{
    RBPluginManager *pluginManager = RBObjectFromString(@"CLAide::Command::PluginManager");
    NSArray *pluginPaths = [pluginManager plugin_load_paths:@"cocoapods"];

    NSMutableArray *pluginNames = [NSMutableArray arrayWithCapacity:pluginPaths.count];
    for (NSString *pluginPath in pluginPaths) {
      NSString *pluginRootPath = [[pluginPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
      RBGemSpecification *spec = [pluginManager specification:pluginRootPath];
      [pluginNames addObject:spec.name];
    }
    reply(pluginNames, nil);

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
