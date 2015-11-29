#import <Foundation/Foundation.h>
#import "CPReflectionService.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)connection;
{
  connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CPReflectionServiceProtocol)];

  CPReflectionService *exportedObject = [CPReflectionService new];
  connection.exportedObject = exportedObject;

  [connection resume];

  return YES;
}

@end

int main(int argc, const char *argv[])
{
  ServiceDelegate *delegate = [ServiceDelegate new];
  NSXPCListener *listener = [NSXPCListener serviceListener];
  listener.delegate = delegate;
  [listener resume];
  return 0;
}
