#import "RBObject+CocoaPods.h"
#import <RubyCocoa/RBRuntime.h>
#import <AppKit/NSAlert.h>

#ifndef NS_BLOCK_ASSERTIONS
#define CP_ENABLE_THREAD_ASSERTIONS
#import <objc/runtime.h>
#endif

@class RBThread;

static RBThread *RBThreadInstance = nil;
static ID ID_to_ruby = 0;
static VALUE rb_cPodInformativeError = Qnil;

static BOOL
CPRubyInit(Class bundleClass)
{
  NSCAssert([NSThread currentThread] == (NSThread *)RBThreadInstance, @"Should only be called from the Ruby thread.");

  // Initialize the Ruby runtime and load our Ruby setup file.
  RBBundleInit("RBObject+CocoaPods.rb", bundleClass, nil);

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
  NSCAssert(!error, @"Failed to load gems");

  ID_to_ruby = rb_intern("to_ruby");
  rb_cPodInformativeError = rb_const_get(rb_const_get(rb_cObject, rb_intern("Pod")), rb_intern("Informative"));

  return error == 0;
}


#pragma mark - Errors

NSString *const CPErrorDomain = @"org.cocoapods.app.ErrorDomain";
NSString *const CPErrorRubyBacktrace = @"backtrace";
NSString *const CPErrorObjCBacktrace = @"objc-backtrace";

static NSError *
CPErrorFromException(NSException * _Nonnull exception)
{
  CPErrorDomainCode code = -1;
  NSString *description  = nil;
  NSString *suggestion   = nil;
  NSArray *rubyBacktrace = nil;

  if ([exception.name hasPrefix:@"RBException_"]) {
    description = @"Uncaught Ruby exception.";
    rubyBacktrace = exception.userInfo[CPErrorRubyBacktrace];

    VALUE rb_exception = [exception.userInfo[@"$!"] __rbobj__];
    if (rb_obj_is_kind_of(rb_exception, rb_cPodInformativeError)) {
      code = CPInformativeError;
    } else {
      code = CPStandardError;
    }
    VALUE message = rb_funcall(rb_exception, rb_intern("message"), 0);
    message = rb_funcall(message, rb_intern("strip"), 0);
    suggestion = @(StringValuePtr(message));

  } else {
    code = CPNonRubyError;
    description = exception.reason;
  }

  NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description,
                  NSLocalizedRecoverySuggestionErrorKey: suggestion,
                                   CPErrorRubyBacktrace: rubyBacktrace,
                                   CPErrorObjCBacktrace: exception.callStackSymbols };

  return [NSError errorWithDomain:CPErrorDomain
                             code:code
                         userInfo:userInfo];
}

static void
CPLogError(NSError * _Nonnull error)
{
  NSString *rubyBacktrace = [error.userInfo[CPErrorRubyBacktrace] componentsJoinedByString:@"\n\t"];
  NSString *objcBacktrace = [error.userInfo[CPErrorObjCBacktrace] componentsJoinedByString:@"\n\t"];
  NSLog(@"[Ruby Thread Exception] %@ - %ld\n%@\n\n\t%@\n\n\t%@", error.domain, error.code, error.localizedRecoverySuggestion, rubyBacktrace, objcBacktrace);
}

#pragma mark - Ruby thread

@interface RBThread : NSThread
@end

@implementation RBThread

- (void)start;
{
  // TODO Figure out why calling RBBundleInit leads to loading WebKit.
  //      Until then, load WebKit from the main thread so that it doesn’t complain.
  [NSClassFromString(@"WebScriptObject") class];

  [super start];
}

- (void)main;
{
  if (CPRubyInit(self.class)) {
    while (1) {
      // There is really no reason for this to be reached, but let’s just be safe.
      //
      // Ensure that the pool gets drained, if an uncaught exception occurs.
      @autoreleasepool {
        @try {
          [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        }
        @catch (NSException *exception) {
          NSAssert(NO, @"Serious error, this shouldn’t be reached.");

          NSError *error = CPErrorFromException(exception);
          CPLogError(error);
          // Show uncaught exceptions modal over the app.
          dispatch_async(dispatch_get_main_queue(), ^{
            [[NSAlert alertWithError:error] runModal];
          });
        }
      }
    }
  }
}

- (void)performTask:(NSArray * _Nonnull)blocks waitUntilDone:(BOOL)waitUntilDone;
{
  if ([NSThread currentThread] == self && waitUntilDone) {
    [self performTask:blocks];
  } else {
    [self performSelector:@selector(performTask:) onThread:self withObject:blocks waitUntilDone:waitUntilDone];
  }
}

- (void)performTask:(NSArray * _Nonnull)blocks;
{
  RBObjectTaskBlock taskBlock = blocks.firstObject;
  RBObjectErrorBlock errorBlock = blocks.lastObject;
  @autoreleasepool {
    @try {
      taskBlock();
    }
    @catch (NSException *exception) {
      NSError *error = CPErrorFromException(exception);
      CPLogError(error);
      errorBlock(error);
    }
  }
}

@end


#pragma mark - Ruby integration

id _Nonnull
RBObjectFromString(NSString * _Nonnull source)
{
  return [RBObject RBObjectWithRubyScriptString:source];
}

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
    if (rb_respond_to(arg, ID_to_ruby)) {
      arg = rb_funcall(arg, ID_to_ruby, 0);
    }
    rb_ary_store(coerced_args, i, arg);
  }
  return coerced_args;
}


+ (void)performBlock:(RBObjectTaskBlock _Nonnull)taskBlock error:(RBObjectErrorBlock _Nonnull)errorBlock;
{
  [RBThreadInstance performTask:@[taskBlock, errorBlock] waitUntilDone:NO];
}

+ (void)performBlockAndWait:(RBObjectTaskBlock _Nonnull)taskBlock error:(RBObjectErrorBlock _Nonnull)errorBlock;
{
  [RBThreadInstance performTask:@[taskBlock, errorBlock] waitUntilDone:YES];
}

@end
