#import <Foundation/Foundation.h>
#import "RMQExchange.h"
#import "AMQProtocolValues.h"
#import "RMQQueue.h"
#import "RMQSender.h"

@interface RMQChannel : NSObject
@property (nonnull, copy, nonatomic, readonly) NSNumber *channelID;
- (nonnull instancetype)init:(nonnull NSNumber *)channelID
                      sender:(nonnull id <RMQSender>)sender;
- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                 autoDelete:(BOOL)shouldAutoDelete
                  exclusive:(BOOL)isExclusive;
- (nonnull RMQExchange *)defaultExchange;
@end
