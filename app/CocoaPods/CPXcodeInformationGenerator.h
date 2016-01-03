#import <Foundation/Foundation.h>

@class CPUserProject, CPXcodeProject, CPCocoaPodsTarget;

@interface CPXcodeInformationGenerator : NSObject

@property (nonatomic, assign, getter=useAsync) BOOL performAsync;

- (void)XcodeProjectMetadataFromUserProject:(CPUserProject * _Nonnull)project reply:(void (^ _Nonnull)(NSArray<CPXcodeProject *> * _Nonnull projects, NSArray<CPCocoaPodsTarget *> * _Nonnull targets, NSError * _Nullable error))reply;


@end
