#import <Foundation/Foundation.h>

extern NSString * _Nonnull const CPErrorDomain;
extern NSString * _Nonnull const CPErrorName;
extern NSString * _Nonnull const CPErrorRubyBacktrace;
extern NSString * _Nonnull const CPErrorObjCBacktrace;

typedef NS_ENUM(NSInteger, CPErrorDomainCode) {
  CPInformativeError, // These are user errors
  CPStandardError,    // These are runtime errors
  CPNonRubyError      // These are errors on the Objective-C side of the bridge
};

