#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ObjcppBridge.h"
#import "RunevmFlPlugin.h"

FOUNDATION_EXPORT double runevm_flVersionNumber;
FOUNDATION_EXPORT const unsigned char runevm_flVersionString[];

