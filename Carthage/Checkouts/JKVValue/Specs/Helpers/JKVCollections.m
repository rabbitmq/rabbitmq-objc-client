#import "JKVCollections.h"

@implementation JKVCollections

- (id)initWithItems:(NSArray *)items pairs:(NSDictionary *)pairs
{
    self = [super init];
    if (self) {
        _items = items;
        _pairs = pairs;
    }
    return self;
}

@end
