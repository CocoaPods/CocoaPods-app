#import "CPReflectionService.h"
#import "RBObject+CocoaPods.h"

@implementation CPReflectionService

- (void)pluginsFromPodfile:(NSString * _Nonnull)contents
                 withReply:(void (^ _Nonnull)(NSArray<NSString *> * _Nullable plugins, NSError * _Nullable error))reply;
{
  [RBObject performBlock:^{
    // It doesn’t really matter what we specify as path, as we’re not using the DSLError informative message.
    RBPathname *pathname = [RBObjectFromString(@"Pathname") new:@"Podfile"];
    
    @try {
      RBPodfile *podfile = [RBObjectFromString(@"Pod::Podfile") from_ruby:pathname :contents];
      NSArray *plugins = podfile.plugins.allKeys;
      reply(plugins, nil);
    }
    
    @catch (NSException *exception) {
      // In case of a Pod::DSLError, try to create a UI syntax error out of it.
      if (![exception.reason isEqualToString:@"Pod::DSLError"]) {
        @throw;
      }

      // TODO: have CocoaPods-Core keep the error message around
      //       https://cocoapods.slack.com/archives/cocoapods-app/p1448669896000284
      RBObject *rubyException = exception.userInfo[@"$!"];
      // TODO -[RBObject description] returns the description of the proxy.
      VALUE descriptionValue = rb_funcall(rubyException.__rbobj__, rb_intern("description"), 0);
      // Example:
      //     Invalid `Podfile` file: undefined local variable or method `s' for #<Pod::Podfile:0x0000010331f390>
      NSString *description = [@(StringValuePtr(descriptionValue)) substringFromIndex:24];
      NSString *firstCharacter = [[description substringToIndex:1] uppercaseString];
      description = [firstCharacter stringByAppendingString:[description substringFromIndex:1]];
      
      reply(nil, CPErrorFromException(exception, description));
    }
    
  } error:^(NSError * _Nonnull error) {
    reply(nil, error);
  }];
}

@end
