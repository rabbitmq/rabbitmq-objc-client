#import "JKVCollections.h"

@interface JKVMutableCollections : JKVCollections
@property (strong, nonatomic, readwrite) NSMutableArray *items;
@property (strong, nonatomic, readwrite) NSMutableDictionary *pairs;

- (id)initWithItems:(NSArray *)items pairs:(NSDictionary *)pairs;
@end
