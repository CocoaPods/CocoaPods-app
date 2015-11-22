#import "RBObject+CocoaPods.h"
#import <RubyCocoa/RBRuntime.h>

#ifndef NS_BLOCK_ASSERTIONS
#define CP_ENABLE_THREAD_ASSERTIONS
#import <objc/runtime.h>
#endif

@interface RBThread : NSThread
@end

@implementation RBThread

- (void)main;
{
  RBBundleInit("RBObject+CocoaPods.rb", self.class, nil);
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
}

- (void)performTask:(void (^ _Nonnull)(void))block waitUntilDone:(BOOL)waitUntilDone;
{
  if ([NSThread currentThread] == self && waitUntilDone) {
    [self performTask:block];
  } else {
    [self performSelector:@selector(performTask:) onThread:self withObject:block waitUntilDone:waitUntilDone];
  }
}

- (void)performTask:(void (^ _Nonnull)(void))block;
{
  @autoreleasepool {
    block();
  }
}

@end

static RBThread *RBThreadInstance = nil;

@implementation RBObject (CocoaPods)

#ifdef CP_ENABLE_THREAD_ASSERTIONS

#define CP_ASSERT_THREAD() NSAssert([NSThread currentThread] == RBThreadInstance, @"RBObject methods should only be called from the designated thread. Use +[RBObject performBlock:] or +[RBObject performBlockAndWait:].");

- (instancetype)cp_initWithRubyScriptCString:(const char*)cstr;
{
  CP_ASSERT_THREAD();
  return [self cp_initWithRubyScriptCString:cstr];
}

- (void)cp_forwardInvocation:(NSInvocation *)invocation;
{
  CP_ASSERT_THREAD();
  [self cp_forwardInvocation:invocation];
}

static void
SwizzleMethods(SEL original, SEL swizzled)
{
  Method originalMethod = class_getInstanceMethod(RBObject.class, original);
  Method swizzledMethod = class_getInstanceMethod(RBObject.class, swizzled);
  method_exchangeImplementations(originalMethod, swizzledMethod);
}

#endif

+ (void)load;
{
#ifdef CP_ENABLE_THREAD_ASSERTIONS
  SwizzleMethods(@selector(initWithRubyScriptCString:), @selector(cp_initWithRubyScriptCString:));
  SwizzleMethods(@selector(forwardInvocation:), @selector(cp_forwardInvocation:));
#endif
  
  RBThreadInstance = [RBThread new];
  RBThreadInstance.name = @"org.cocoapods.app.RBObjectThread";
  [RBThreadInstance start];
}

+ (void)performBlock:(void (^ _Nonnull)(void))block;
{
  [RBThreadInstance performTask:block waitUntilDone:NO];
}

+ (void)performBlockAndWait:(void (^ _Nonnull)(void))block;
{
  [RBThreadInstance performTask:block waitUntilDone:YES];
}

@end
