#import "CPXcodeInformationGenerator.h"
#import "CocoaPods-Swift.h"
#import "NSArray+Helpers.h"

@implementation CPXcodeInformationGenerator

- (void)XcodeProjectMetadataFromUserProject:(CPUserProject *)project reply:(void (^ _Nonnull)(NSArray<CPXcodeProject *> * _Nonnull projects, NSArray<CPCocoaPodsTarget *> * _Nonnull targets, NSError * _Nullable error))reply
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    NSArray *xcodeprojects = [self xcodeProjectsFromProject:project];
    NSArray *targets = [self cocoapodsTargetsFromProject:project];

    dispatch_async(dispatch_get_main_queue(), ^{
      reply(xcodeprojects, targets, nil);
    });
  });
}

- (NSArray<CPXcodeProject *> * _Nonnull)xcodeProjectsFromProject:(CPUserProject *)project
{
  NSDictionary *xcodeprojs = project.xcodeIntegrationDictionary[@"projects"];
  BOOL usesFrameworks = project.xcodeIntegrationDictionary[@"uses_frameworks"] != [NSNull null];

  // We promise non-null, so return empty array
  if (xcodeprojs.allKeys.count == 0) { return @[]; }

  return [xcodeprojs.allKeys map:^ id (NSString *path) {
    CPXcodeProject *xcProject = [[CPXcodeProject alloc] init];
    xcProject.filePath = [NSURL fileURLWithPath:path];
    xcProject.fileName = [path lastPathComponent];
    xcProject.integrationType = usesFrameworks ? @"Frameworks" : @"Static Libraries";
    xcProject.plugins = project.podfilePlugins;

    NSDictionary *targetsDict = xcodeprojs[path][@"targets"];
    NSArray *sortedKeys = [targetsDict.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    xcProject.targets = [sortedKeys map:^id(NSString *name) {
      NSDictionary *targetData = targetsDict[name];

// TODO: Figure out if anything is worth the hassle of going through plists/xcodeprojects
//       off-hand my only thought is target version number / icon. They aren't blockers
//       though, and would be brittle.
//
//      NSURL *podfileFolder = [project.filePath URLByDeletingLastPathComponent];
//      NSURL *plistURL = [podfileFolder URLByAppendingPathComponent:targetData[@"info_plist"]];
//      NSDictionary *targetPlist = [NSDictionary dictionaryWithContentsOfURL:plistURL];

      CPXcodeTarget *target = [[CPXcodeTarget alloc] init];
      target.platform = targetData[@"platform"];
      target.type = prettyBundleType(targetData[@"type"]);
      target.name = name;
      target.cocoapodsTargets = targetData[@"pod_targets"];
      target.icon = [NSImage imageNamed:iconName(targetData[@"platform"], targetData[@"type"])];
      return target;
    }] ?: @[];

    return xcProject;
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


static NSString *prettyBundleType(NSString *string) {
  NSDictionary *mapping = @{
    @"com.apple.product-type.application" : @"App",
    @"com.apple.product-type.framework" : @"Framework",
    @"com.apple.product-type.library.dynamic" : @"Dynamic Library",
    @"com.apple.product-type.library.static" : @"Static Library",
    @"com.apple.product-type.bundle" : @"Bundle",
    @"com.apple.product-type.bundle.unit-test" : @"Test Bundle",
    @"com.apple.product-type.bundle.ui-testing" : @"UI Testing Bundle",
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

// These icons can be found in Podfile.xcassets
static NSString *iconName(NSString *platform, NSString *type) {
  if ([type isEqualToString:@"com.apple.product-type.application"]) {
    if ([platform hasPrefix:@"tvOS"]) return @"TVOS-Icon";
    if ([platform hasPrefix:@"iOS"]) return @"iOS-Icon";
    if ([platform hasPrefix:@"OS X"]) return @"OSX-Icon";
    if ([platform hasPrefix:@"watchOS"]) return @"watchOS-Icon";
    return @"unknown-Icon";
  }
  if ([type isEqualToString:@"com.apple.product-type.bundle.unit-test"] || [type isEqualToString:@"com.apple.product-type.bundle.ui-testing"]) return @"Bundle-Tests-Icon";
  return @"Bundle-Icon";
}


@end

