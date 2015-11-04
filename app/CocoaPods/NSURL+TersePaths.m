#import "NSURL+TersePaths.h"

@implementation NSURL(TersePaths)

- (NSString *)tersePath
{
  NSString *components = [self.pathComponents componentsJoinedByString:@"/"];
  return [components stringByAbbreviatingWithTildeInPath];
}

@end
