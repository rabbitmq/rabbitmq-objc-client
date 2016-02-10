#import "AMQEncoder.h"

@implementation AMQEncoder

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod
               channelID:(NSNumber *)channelID {
    return [[AMQFrame alloc] initWithType:@(1)
                                channelID:channelID
                                   method:amqMethod].amqEncoded;
}

@end
