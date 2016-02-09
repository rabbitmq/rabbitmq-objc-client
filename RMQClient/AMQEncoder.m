#import "AMQEncoder.h"

@implementation AMQEncoder

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod
                 channel:(RMQChannel *)channel {
    return [[AMQFrame alloc] initWithType:@(1)
                                channelID:channel.channelID
                                   method:amqMethod].amqEncoded;
}

@end
