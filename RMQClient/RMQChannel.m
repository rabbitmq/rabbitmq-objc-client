#import "RMQChannel.h"

@implementation RMQChannel
- (RMQQueue *)queue:(NSString *)queueName
         autoDelete:(BOOL)shouldAutoDelete
          exclusive:(BOOL)isExclusive {
    return [RMQQueue new];
}
- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}
- (void)close {
    
}
- (AMQProtocolBasicConsumeOK *)basicConsume:(RMQQueue *)queue {
    return [AMQProtocolBasicConsumeOK new];
}
- (AMQProtocolBasicConsumeOK *)basicConsume:(RMQQueue *)queue
                                consumerTag:(NSString *)consumerTag
                                        ack:(BOOL)shouldAck
                                  exclusive:(BOOL)isExclusive
                                 onDelivery:(void (^)(NSDictionary *,
                                                      NSDictionary *,
                                                      NSData *))onDelivery {
    return [AMQProtocolBasicConsumeOK new];
}
@end
