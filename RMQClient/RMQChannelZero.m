#import "RMQChannelZero.h"

@interface RMQChannelZero ()
@property (nonatomic, readwrite) NSNumber *channelNumber;
@end

@implementation RMQChannelZero

- (RMQExchange *)defaultExchange { return nil; }
- (void)open {}
- (void)activateWithDelegate:(id<RMQConnectionDelegate>)delegate {}
- (RMQQueue *)queue:(NSString *)queueName { return nil; }
- (RMQQueue *)queue:(NSString *)queueName options:(AMQQueueDeclareOptions)options { return nil; }
- (void)basicConsume:(NSString *)queueName options:(AMQBasicConsumeOptions)options consumer:(void (^)(id<RMQMessage> _Nonnull))consumer {}
- (void)basicGet:(NSString *)queue options:(AMQBasicGetOptions)options completionHandler:(void (^)(id<RMQMessage> _Nonnull))completionHandler {}
- (void)basicPublish:(NSString *)message routingKey:(NSString *)routingKey exchange:(NSString *)exchange {}
- (void)basicQos:(NSNumber *)count global:(BOOL)isGlobal {}
- (void)ack:(NSNumber *)deliveryTag {}
- (void)ack:(NSNumber *)deliveryTag options:(AMQBasicAckOptions)options {}
- (void)reject:(NSNumber *)deliveryTag {}
- (void)reject:(NSNumber *)deliveryTag options:(AMQBasicRejectOptions)options {}

# pragma mark - AMQFrameHandler

- (void)handleFrameset:(AMQFrameset *)frameset {}

@end
