#import "CPHomeWindowDocumentEntry.h"
#import "NSURL+TersePaths.h"

@implementation CPHomeWindowDocumentEntry

- (instancetype)copyWithZone:(NSZone *)zone
{
  CPHomeWindowDocumentEntry *copy = [[[self class] allocWithZone:zone] init];
  if (copy) {
    [copy setName:[self.name copyWithZone:zone]];
    [copy setPodfileURL:[self.podfileURL copyWithZone:zone]];
    [copy setImage:[self.image copyWithZone:zone]];
    [copy setFileDescription:[self.fileDescription copyWithZone:zone]];
  }

  return copy;
}

+ (CPHomeWindowDocumentEntry *)documentEntryWithURL:(NSURL *)url
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *dirFiles = [fileManager contentsOfDirectoryAtURL:[url URLByDeletingLastPathComponent] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];

  NSPredicate *workspacePredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'xcworkspace'"];
  NSPredicate *projectPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'xcodeproj'"];
  NSURL *workspaceURL = [[dirFiles filteredArrayUsingPredicate:workspacePredicate] firstObject];
  NSURL *projectURL = [[dirFiles filteredArrayUsingPredicate:projectPredicate] firstObject];
  NSURL *bestURL = workspaceURL ?: projectURL ?: url;

  CPHomeWindowDocumentEntry *document = [CPHomeWindowDocumentEntry new];
  document.name = [bestURL lastPathComponent];
  document.image = [NSImage imageNamed:@"Podfile-icon"];
  document.podfileURL = url;
  document.fileDescription = workspaceURL? @"Podfile" : [bestURL tersePath];
  return document;
}


@end