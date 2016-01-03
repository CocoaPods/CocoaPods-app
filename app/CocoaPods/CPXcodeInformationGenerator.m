#import "CPXcodeInformationGenerator.h"
#import "CocoaPods-Swift.h"
#import "NSArray+Helpers.h"

@implementation CPXcodeInformationGenerator

- (void)XcodeProjectMetadataFromUserProject:(CPUserProject *)project reply:(void (^ _Nonnull)(NSArray<CPXcodeProject *> * _Nonnull projects, NSArray<CPCocoaPodsTarget *> * _Nonnull targets, NSError * _Nullable error))reply
{
  NSArray *xcodeprojects = [self xcodeProjectsFromProject:project];
  NSArray *targets = [self cocoapodsTargetsFromProject:project];
  reply(xcodeprojects, targets, nil);
}

- (NSArray<CPXcodeProject *> * _Nonnull)xcodeProjectsFromProject:(CPUserProject *)project
{
  NSDictionary *xcodeprojs = project.xcodeIntegrationDictionary[@"projects"];
  // We promise non-null, so return empty array
  if (xcodeprojs.allKeys.count == 0) { return @[]; }

  return [xcodeprojs.allKeys map:^ id (NSString *path) {
    CPXcodeProject *project = [[CPXcodeProject alloc] init];
    project.filePath = [NSURL fileURLWithPath:path];
    project.fileName = [path lastPathComponent];

    NSDictionary *targetsDict = xcodeprojs[path][@"targets"];
    NSArray *sortedKeys = [targetsDict.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    project.targets = [sortedKeys map:^id(NSString *name) {
      NSDictionary *targetData = targetsDict[name];

      NSURL *podfileFolder = [project.filePath URLByDeletingLastPathComponent];
      NSURL *plistURL = [podfileFolder URLByAppendingPathComponent:targetData[@"info_plist"]];
      NSDictionary *targetPlist = [NSDictionary dictionaryWithContentsOfURL:plistURL];

      CPXcodeTarget *target = [[CPXcodeTarget alloc] init];
      target.platform = targetData[@"platform"];
      target.type = prettyBundleType(targetData[@"type"]);
      target.name = name;
      target.cocoapodsTargets = targetData[@"pod_targets"];

      return target;
    }] ?: @[];

    return project;
  }];
}

- (NSArray<CPCocoaPodsTarget *> * _Nonnull)cocoapodsTargetsFromProject:(CPUserProject *)project
{
  NSDictionary *podTargets = project.xcodeIntegrationDictionary[@"pod_targets"];
  // We promise non-null, so return empty array
  if (podTargets.allKeys.count == 0) { return @[]; }

  return [podTargets.allKeys map:^ id (NSString *name) {
    CPCocoaPodsTarget *target = [[CPCocoaPodsTarget alloc] init];
    target.name = name;
    NSArray *pods = podTargets[name];
    target.pods = [pods map:^id(id name) {
      return [[CPPod alloc] initWithName:name version:@""];
    }];
    return target;
  }];
}


NSString *prettyBundleType(NSString *string) {
  NSDictionary *mapping = @{
    @"com.apple.product-type.application" : @"App",
    @"com.apple.product-type.framework" : @"Framework",
    @"com.apple.product-type.library.dynamic" : @"Dynamic Library",
    @"com.apple.product-type.library.static" : @"Static Library",
    @"com.apple.product-type.bundle" : @"Bundle",
    @"com.apple.product-type.bundle.unit-test" : @"Test Bundle",
    @"com.apple.product-type.app-extension" : @"App Extension",
    @"com.apple.product-type.tool" : @"Command Line Tool",
    @"com.apple.product-type.application.watchapp" : @"Watch App",
    @"com.apple.product-type.application.watchapp2" : @"watchOS 2 App",
    @"com.apple.product-type.watchkit-extension" : @"Watch Extension",
    @"com.apple.product-type.watchkit2-extension" : @"watchOS2 Extension",
    @"com.apple.product-type.tv-app-extension" : @"TV Extension"
  };
  return mapping[string] ?: string;
}

@end

