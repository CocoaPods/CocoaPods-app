#import "RBObject+CocoaPods.h"
#import <RubyCocoa/RBRuntime.h>

#ifndef NS_BLOCK_ASSERTIONS
#define CP_ENABLE_THREAD_ASSERTIONS
#import <objc/runtime.h>
#endif


id _Nonnull
RBObjectFromString(NSString * _Nonnull source)
{
  return [RBObject RBObjectWithRubyScriptString:source];
}



@interface RBThread : NSThread
@end

@implementation RBThread

- (void)main;
{
  // Initialize the Ruby runtime and load our Ruby setup file.
  RBBundleInit("RBObject+CocoaPods.rb", self.class, nil);

  // These are C exts that are included in libruby, but we need
  // to initialize them ourselves and tell the runtime that they
  // have been loaded (provided).
  #define INIT_EXT(name) void Init_##name(void); Init_##name();
  #define PROVIDE_EXT(name) INIT_EXT(name); rb_provide(#name);
  rb_provide("thread");
  INIT_EXT(pathname);
  rb_provide("pathname.so");
  PROVIDE_EXT(date_core);
  PROVIDE_EXT(bigdecimal);
  PROVIDE_EXT(stringio);

  // Now we can load RubyGems and the gems we need.
  int error = 0;
  rb_eval_string_protect("require 'rubygems'; require 'cocoapods-core'", &error);
  NSAssert(!error, @"Failed to load gems");

  if (!error) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
  }
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
static ID to_ruby;

@interface RBObject (Private)
- (VALUE)fetchForwardArgumentsOf:(NSInvocation *)invocation;
@end

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

#endif

static void
SwizzleMethods(SEL original, SEL swizzled)
{
  Method originalMethod = class_getInstanceMethod(RBObject.class, original);
  Method swizzledMethod = class_getInstanceMethod(RBObject.class, swizzled);
  method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)load;
{
#ifdef CP_ENABLE_THREAD_ASSERTIONS
  SwizzleMethods(@selector(initWithRubyScriptCString:), @selector(cp_initWithRubyScriptCString:));
  SwizzleMethods(@selector(forwardInvocation:), @selector(cp_forwardInvocation:));
#endif
  SwizzleMethods(@selector(fetchForwardArgumentsOf:), @selector(cp_fetchForwardArgumentsOf:));
  
  RBThreadInstance = [RBThread new];
  RBThreadInstance.name = @"org.cocoapods.app.RBObjectThread";
  [RBThreadInstance start];
  
  [self performBlock:^{
    to_ruby = rb_intern("to_ruby");
  }];
}

// Automatically convert all NSObject objects to their Ruby
// counterparts by calling RubyCocoa’s NSObject#to_ruby on them.
//
// TODO Might make sense to submit this to RubyCocoa, but not yet
// sure how the user would configure it.
- (VALUE)cp_fetchForwardArgumentsOf:(NSInvocation *)invocation;
{
  // Call original RubyCocoa implementation.
  VALUE args = [self cp_fetchForwardArgumentsOf:invocation];

  int count = RARRAY_LENINT(args);
  VALUE coerced_args = rb_ary_new2(count);
  for (int i = 0; i < count; i++) {
    VALUE arg = rb_ary_entry(args, i);
    if (rb_respond_to(arg, to_ruby)) {
      arg = rb_funcall(arg, to_ruby, 0);
    }
    rb_ary_store(coerced_args, i, arg);
  }
  return coerced_args;
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
