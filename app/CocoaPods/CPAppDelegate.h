#import <Cocoa/Cocoa.h>

@interface CPAppDelegate : NSObject <NSApplicationDelegate>
@property (readonly) NSXPCConnection *reflectionService;
@end
