#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class SMLSyntaxError;

/// A CPUserProject is a project that is pretty much always
/// represented by a Podfile, while it may have overlap
/// the job of actually representing the Podfile and it's
/// metadata is handled by `CPPodfile` from CocoaPods-ObjC

@class CPUserProject;

@protocol CPUserProjectDelegate <NSObject>

- (void)contentDidChangeinUserProject:(CPUserProject *)userProject;

@end

@interface CPUserProject : NSDocument

@property (nonatomic, weak) id<CPUserProjectDelegate> delegate;

/// The raw string content of the Podfile
@property (strong) NSString * contents;

/// Registerable properties
/// Note: These _start out_ as nil, but can only be changed to
/// non-null objects, thus allowing us to check for existence
/// for the registering promise.

/// Plugins that are used within the Podfile
@property (nonatomic, strong) NSArray <NSString *> *podfilePlugins;

/// Sources that are used by the project
@property (nonatomic, strong) NSArray<NSString *> *podfileSources;

/// The Xcodeprojects and CP Targets that are represented by the Podfile
@property (nonatomic, strong) NSDictionary *xcodeIntegrationDictionary;

/// Syntax errors retrived from reflection service
@property (nonatomic, strong) NSArray <SMLSyntaxError *> *syntaxErrors;

/// Register for when podfilePlugins and the xcodeIntegrationDictionary are filled
- (void)registerForFullMetadataCallback:(void (^)(void))completion;

NS_ASSUME_NONNULL_END

/// Path to the Lockfile. returns nil if the Lockfile hasn't been created yet.
- (NSString * _Nullable)lockfilePath;

@end
