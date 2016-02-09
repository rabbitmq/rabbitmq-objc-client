#import "AMQEncoder.h"

@implementation AMQEncoder

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod {
    return [[AMQFrame alloc] initWithType:@(1) channelID:@(0) method:amqMethod].amqEncoded;
}

@end
