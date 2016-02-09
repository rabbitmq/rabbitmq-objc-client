#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"
#import "RMQChannel.h"

@interface AMQEncoder : NSObject
- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod
                 channel:(RMQChannel *)channel;
@end
