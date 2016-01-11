#import <Foundation/Foundation.h>
#import "RMQQueue.h"
#import "RMQExchange.h"
#import "AMQProtocol.h"

@interface RMQChannel : NSObject
- (RMQQueue *)queue:(NSString *)queueName
         autoDelete:(BOOL)shouldAutoDelete
          exclusive:(BOOL)isExclusive;
- (RMQExchange *)defaultExchange;
- (void)close;
- (AMQProtocolBasicConsumeOK *)basicConsume:(RMQQueue *)queue;
- (AMQProtocolBasicConsumeOK *)basicConsume:(RMQQueue *)queue
                                consumerTag:(NSString *)consumerTag
                                        ack:(BOOL)shouldAck
                                  exclusive:(BOOL)isExclusive
                                 onDelivery:(void (^)(NSDictionary *deliveryInfo,
                                                      NSDictionary *properties,
                                                      NSData *deliveredData))onDelivery;
@end
