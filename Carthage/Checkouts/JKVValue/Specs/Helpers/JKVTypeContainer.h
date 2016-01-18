#import <Foundation/Foundation.h>
#import "JKVMutableValue.h"
#import <TargetConditionals.h>
#import <CoreGraphics/CoreGraphics.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface JKVTypeContainer : JKVMutableValue

@property (nonatomic, strong) NSString *obj;
@property (nonatomic, assign) NSInteger integer;
@property (nonatomic, assign, getter=isBoolean) BOOL boolean;
@property (atomic, assign) float floatValue;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) int16_t int16Value;
@property (nonatomic, assign) int32_t int32Value;
@property (nonatomic, assign) int64_t int64Value;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CGSize size;

#if TARGET_OS_IPHONE
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) UIOffset offset;
#elif TARGET_OS_MAC
@property (nonatomic, assign) NSPoint nsPoint;
@property (nonatomic, assign) NSRect nsRect;
@property (nonatomic, assign) NSSize nsSize;
#endif

- (id)initWithPresetData;

@end
