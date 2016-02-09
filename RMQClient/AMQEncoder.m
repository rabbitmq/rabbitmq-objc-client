#import "AMQEncoder.h"

@interface AMQEncoder ()
@property (nonatomic, readwrite) NSMutableData *data;
@end

@implementation AMQEncoder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.data = [NSMutableData new];
    }
    return self;
}

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod {
    return [[AMQFrame alloc] initWithType:@(1) channelID:@(0) method:amqMethod].amqEncoded;
}

@end
