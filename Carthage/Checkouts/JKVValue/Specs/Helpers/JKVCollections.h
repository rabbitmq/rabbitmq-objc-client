#import "JKVValue.h"

@interface JKVCollections : JKVValue
@property (strong, nonatomic, readonly) NSArray *items;
@property (strong, nonatomic, readonly) NSDictionary *pairs;

- (id)initWithItems:(NSArray *)items pairs:(NSDictionary *)pairs;
@end
