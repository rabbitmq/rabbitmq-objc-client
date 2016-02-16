#import "AMQEncoder.h"

@implementation AMQEncoder

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod
               channelID:(NSNumber *)channelID {
    return [[AMQFrameset alloc] initWithType:@(1)
                                   channelID:channelID
                                      method:amqMethod].amqEncoded;
}

@end
