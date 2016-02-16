#import "AMQEncoder.h"

@implementation AMQEncoder

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod
               channelID:(NSNumber *)channelID {
    return [[AMQFrameset alloc] initWithTypeID:@(1)
                                     channelID:channelID
                                        method:amqMethod].amqEncoded;
}

@end
