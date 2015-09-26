#import "CPRecentDocumentsController.h"

@implementation CPHomeWindowDocumentEntry

- (instancetype)copyWithZone:(NSZone *)zone
{
  CPHomeWindowDocumentEntry *copy = [[[self class] allocWithZone:zone] init];
  if (copy) {
    [copy setName:[self.name copyWithZone:zone]];
    [copy setPodfileURL:[self.podfileURL copyWithZone:zone]];
    [copy setImage:[self.image copyWithZone:zone]];
    [copy setFolderPath:[self.folderPath copyWithZone:zone]];
  }

  return copy;
}

@end

@implementation CPRecentDocumentsController

- (void)awakeFromNib
{
  [super awakeFromNib];
  [self setupRecentDocuments];
}

- (void)setupRecentDocuments
{
  NSDocumentController *controller = [NSDocumentController sharedDocumentController];
  NSMutableArray *documents = [NSMutableArray arrayWithCapacity:controller.recentDocumentURLs.count];
  for (NSURL *url in controller.recentDocumentURLs) {
    [documents addObject:[self projectDetailsAtURL:url]];
  }

  self.recentDocuments = documents;
}

- (CPHomeWindowDocumentEntry *)projectDetailsAtURL:(NSURL *)url
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
  document.folderPath = [[bestURL pathComponents] componentsJoinedByString:@"/"];
  document.image = [[NSWorkspace sharedWorkspace] iconForFile:bestURL.absoluteString];
  document.podfileURL = url;
  return document;
}

@end
