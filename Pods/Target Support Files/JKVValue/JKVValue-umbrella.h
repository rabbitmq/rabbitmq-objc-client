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

#import "JKVFactory.h"
#import "JKVMutableValue.h"
#import "JKVObjectPrinter.h"
#import "JKVValue.h"
#import "JKVValueImpl.h"

FOUNDATION_EXPORT double JKVValueVersionNumber;
FOUNDATION_EXPORT const unsigned char JKVValueVersionString[];

