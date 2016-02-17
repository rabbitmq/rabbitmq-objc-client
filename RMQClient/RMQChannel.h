#import <Foundation/Foundation.h>
#import "RMQExchange.h"
#import "AMQProtocolValues.h"
#import "RMQTransport.h"
#import "RMQQueueFactory.h"

@interface RMQChannel : NSObject
@property (nonnull, copy, nonatomic, readonly) NSNumber *channelID;
- (nonnull instancetype)init:(nonnull NSNumber *)channelID
                   transport:(nonnull id<RMQTransport>)transport
                replyContext:(nonnull id<AMQReplyContext>)replyContext
                queueFactory:(nonnull RMQQueueFactory *)queueFactory;
- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                 autoDelete:(BOOL)shouldAutoDelete
                  exclusive:(BOOL)isExclusive;
- (nonnull RMQExchange *)defaultExchange;
@end
