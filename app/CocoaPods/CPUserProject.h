#import <Cocoa/Cocoa.h>

/// A CPUserProject is a project that is pretty much always
/// represented by a Podfile, while it may have overlap
/// the job of actually representing the Podfile and it's
/// metadata is handled by `CPPodfile` from CocoaPods-ObjC

@interface CPUserProject : NSDocument

@property (strong) NSString *contents;
@property (strong) NSArray *podfilePlugins;

@end
