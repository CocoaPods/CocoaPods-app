#import "CPReflectionService.h"
#import "RBObject+CocoaPods.h"

@implementation CPReflectionService

- (void)pluginsFromPodfile:(NSString * _Nonnull)contents
                 withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;
{
  [RBObject performBlock:^{
    // It doesn’t really matter what we specify as path, as we’re not using the DSLError informative message.
    RBPathname *pathname = [RBObjectFromString(@"Pathname") new:@"Podfile"];

    @try {
      RBPodfile *podfile = [RBObjectFromString(@"Pod::Podfile") from_ruby:pathname :contents];
      NSArray *plugins = podfile.plugins.allKeys;
      reply(plugins, nil);
    }

    @catch (NSException *exception) {
      // In case of a Pod::DSLError, try to create a UI syntax error out of it.
      if (![exception.reason isEqualToString:@"Pod::DSLError"]) {
        @throw;
      }
      RBException *rubyException = exception.userInfo[@"$!"];
      RBException *cause = rubyException.cause;
      NSError *error = CPErrorFromException(exception, cause.message);
      reply(nil, error);
    }

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

@end
