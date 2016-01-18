#import "JKVTypeContainer.h"

@implementation JKVTypeContainer

- (id)initWithPresetData
{
    self = [super init];
    if (self) {
        self.obj = @"Hello World";
        self.integer = 2;
        self.boolean = YES;
        self.floatValue = 2.5;
        self.doubleValue = 5.0;
        self.int16Value = 16;
        self.int32Value = 32;
        self.int64Value = 64;
        self.point = CGPointMake(2, 3);
        self.size = CGSizeMake(3, 4);
        self.rect = CGRectMake(5, 6, 7, 8);
#if TARGET_OS_IPHONE
        self.edgeInsets = UIEdgeInsetsMake(1, 2, 3, 4);
        self.offset = UIOffsetMake(5, 10);
#elif TARGET_OS_MAC
        self.nsPoint = NSMakePoint(2, 3);
        self.nsSize = NSMakeSize(3, 4);
        self.nsRect = NSMakeRect(5, 6, 7, 8);
#endif
    }
    return self;
}

@end
