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
    project.targets = [targetsDict.allKeys map:^id(NSString *name) {
      NSDictionary *targetData = targetsDict[name];

      NSURL *podfileFolder = [project.filePath URLByDeletingLastPathComponent];
      NSURL *plistURL = [podfileFolder URLByAppendingPathComponent:targetData[@"info_plist"]];
      NSDictionary *targetPlist = [NSDictionary dictionaryWithContentsOfURL:plistURL];

      CPXcodeTarget *target = [[CPXcodeTarget alloc] init];
      target.platform = targetData[@"platform"];
      target.type = targetData[@"type"];
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


@end

