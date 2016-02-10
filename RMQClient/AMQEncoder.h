#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"
#import "RMQChannel.h"

@interface AMQEncoder : NSObject
- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod
               channelID:(NSNumber *)channelID;
@end
