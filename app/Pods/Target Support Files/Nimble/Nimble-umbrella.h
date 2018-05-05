#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Nimble.h"
#import "DSL.h"
#import "NMBExceptionCapture.h"

FOUNDATION_EXPORT double NimbleVersionNumber;
FOUNDATION_EXPORT const unsigned char NimbleVersionString[];

