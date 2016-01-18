#import "JKVMutableCollections.h"

@implementation JKVMutableCollections

@synthesize items = _items;
@synthesize pairs = _pairs;

- (id)initWithItems:(NSArray *)items pairs:(NSDictionary *)pairs
{
    self = [super init];
    if (self) {
        _items = [items mutableCopy];
        _pairs = [pairs mutableCopy];
    }
    return self;
}

@end
