#import "NSURL+TersePaths.h"

@implementation NSURL(TersePaths)

- (NSString *)tersePath
{
  NSString *home = [@"~" stringByExpandingTildeInPath];
  NSString *components = [self.pathComponents componentsJoinedByString:@"/"];

  // Probably a better way to do this, but this is reliable.
  NSString *prettyPath = [components stringByReplacingOccurrencesOfString:home withString:@"~"];
  return [prettyPath stringByReplacingOccurrencesOfString:@"/~" withString:@"~"];
}

@end
