#import "RBObject+CocoaPods.h"
#import "CPRubyErrors.h"

#import <RubyCocoa/RBRuntime.h>
#import <AppKit/NSAlert.h>
#import <objc/runtime.h>

#ifndef NS_BLOCK_ASSERTIONS
#define CP_ENABLE_THREAD_ASSERTIONS
#endif

@class RBThread;

static RBThread *RBThreadInstance = nil;
static ID ID_to_ruby = 0;
static VALUE rb_cPodInformativeError = Qnil;


static void
CPRubyInit(Class bundleClass)
{
  NSCAssert([NSThread currentThread] == (NSThread *)RBThreadInstance, @"Should only be called from the Ruby thread.");

  // setenv("RUBYCOCOA_DEBUG", "1", 1);

  // Initialize the Ruby runtime and load our Ruby setup file.
  RBBundleInit("RBObject+CocoaPods.rb", bundleClass, nil);

  // These are C exts that are included in libruby, but we need
  // to initialize them ourselves and tell the runtime that they
  // have been loaded (provided).
  rb_provide("thread");

  #define INIT_EXT(name) void Init_##name(void); Init_##name();

  // Load encoding related extensions
  INIT_EXT(encdb);
  rb_provide("enc/trans/single_byte");
  INIT_EXT(transdb);
  
  // These encodings are used by Psych (YAML extension) and are normally autoloaded by load_encoding in encoding.c,
  // however this does not happen in static libruby or I simply have not figured out how to make it work normally.
  INIT_EXT(utf_16le);
  INIT_EXT(utf_16be);
  INIT_EXT(utf_32le);
  INIT_EXT(utf_32be);
  INIT_EXT(windows_31j);

  INIT_EXT(pathname);
  rb_provide("pathname.so");
  INIT_EXT(digest);
  rb_provide("digest.so");
  INIT_EXT(fiddle);
  rb_provide("fiddle.so");
  INIT_EXT(psych);
  rb_provide("psych.so");
  INIT_EXT(socket);
  rb_provide("socket.so");
  INIT_EXT(md5);
  rb_provide("digest/md5.so");

  #define PROVIDE_EXT(name) INIT_EXT(name); rb_provide(#name);
  PROVIDE_EXT(bigdecimal);
  PROVIDE_EXT(date_core);
  PROVIDE_EXT(stringio);
  PROVIDE_EXT(strscan);

  // Now we can load RubyGems and the gems we need.
  RBApp *app = RBObjectFromString(@"Pod::App");
  NSCParameterAssert(app);
  [app require_gems];

  ID_to_ruby = rb_intern("to_ruby");
  rb_cPodInformativeError = rb_const_get(rb_const_get(rb_cObject, rb_intern("Pod")), rb_intern("Informative"));
}


#pragma mark - Conversions
// Alas, RubyCocoa does not export the ocdata_conv.h header.
// TODO If we need more polymorphic transforms in the future, see about making that header public.

static NSString * _Nullable
RBString(VALUE rb_string)
{
  return rb_string == Qnil ? nil : @(StringValuePtr(rb_string));
}

static NSArray<NSString *> * _Nonnull
RBStringArray(VALUE rb_array)
{
  long size = RARRAY_LEN(rb_array);
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:size];
  for (long i = 0; i < size; i++) {
    [array addObject:RBString(rb_ary_entry(rb_array, i))];
  }
  return array;
}


#pragma mark - Errors

NSError * _Nonnull
CPErrorFromRubyException(VALUE rb_exception, NSArray * _Nullable objcBacktrace)
{
  CPErrorDomainCode code;
  if (rb_obj_is_kind_of(rb_exception, rb_cPodInformativeError)) {
    code = CPInformativeError;
  } else {
    code = CPStandardError;
  }

  NSMutableDictionary *userInfo = [NSMutableDictionary new];
  userInfo[NSLocalizedDescriptionKey] = @"Uncaught Ruby exception.";
  userInfo[CPErrorName] = RBString(rb_class_name(rb_obj_class(rb_exception)));
  userInfo[CPErrorRubyBacktrace] = RBStringArray(rb_funcall(rb_exception, rb_intern("backtrace"), 0));

  NSString *message = RBString(rb_funcall(rb_exception, rb_intern("message"), 0));
  message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  userInfo[NSLocalizedRecoverySuggestionErrorKey] = message;

  if (objcBacktrace) {
    userInfo[CPErrorObjCBacktrace] = objcBacktrace;
  }

  VALUE rb_cause = rb_funcall(rb_exception, rb_intern("cause"), 0);
  if (rb_cause != Qnil) {
    userInfo[NSUnderlyingErrorKey] = CPErrorFromRubyException(rb_cause, nil);
  }

  return [NSError errorWithDomain:CPErrorDomain
                             code:code
                         userInfo:userInfo];
}

NSError * _Nonnull
CPErrorFromException(NSException * _Nonnull exception, NSString * _Nullable message)
{
  if ([exception.name hasPrefix:@"RBException_"]) {
    VALUE rb_exception = [exception.userInfo[@"$!"] __rbobj__];
    return CPErrorFromRubyException(rb_exception, exception.callStackSymbols);
  } else {
    NSDictionary *userInfo = @{
      NSLocalizedDescriptionKey: exception.reason,
      CPErrorName: exception.name,
      CPErrorObjCBacktrace: exception.callStackSymbols
    };
    return [NSError errorWithDomain:CPErrorDomain code:CPNonRubyError userInfo:userInfo];
  }
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
  CPRubyInit(self.class);
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

        NSError *error = CPErrorFromException(exception, nil);
        CPLogError(error);
        // Show uncaught exceptions modal over the app.
        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSAlert alertWithError:error] runModal];
        });
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
      NSError *error = CPErrorFromException(exception, nil);
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

#pragma mark - Debug

// Currently RBObject already respond to -description and just returns that of the proxy.
// TODO Move this upstream?
- (NSString *)description;
{
  VALUE description = rb_funcall(self.__rbobj__, rb_intern("inspect"), 0);
  return [NSString stringWithFormat:@"<RBObject (%p): %s>", self, StringValuePtr(description)];
}

@end
