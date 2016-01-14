#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/// A CPUserProject is a project that is pretty much always
/// represented by a Podfile, while it may have overlap
/// the job of actually representing the Podfile and it's
/// metadata is handled by `CPPodfile` from CocoaPods-ObjC

@interface CPUserProject : NSDocument

/// The raw string content of the Podfile
@property (strong) NSString * contents;

/// Registerable properties
@property (strong) NSArray <NSString *>*podfilePlugins;
@property (strong) NSDictionary *xcodeIntegrationDictionary;

/// Register for when podfilePlugins and the xcodeIntegrationDictionary are filled
- (void)registerForFullMetadata:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END