#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@protocol RMQSender <NSObject>
- (void)send:(id<AMQEncoding>)encodable;
- (void)sendMethod:(id<AMQMethod>)amqMethod channelID:(NSNumber *)channelID;
@end
