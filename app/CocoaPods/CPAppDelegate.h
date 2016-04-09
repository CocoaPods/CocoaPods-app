#import <Cocoa/Cocoa.h>

@class CPDocumentController;
@interface CPAppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) IBOutlet CPDocumentController *documentController; // This allows it to be initialized in time to replace `[NSDocumentController sharedController]`'s default instance
@property (readonly) NSXPCConnection *reflectionService;
@end
