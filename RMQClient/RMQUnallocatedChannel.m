#import "RMQUnallocatedChannel.h"
#import "RMQConstants.h"
#import "RMQConnectionDelegate.h"

@interface RMQUnallocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@end

@implementation RMQUnallocatedChannel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channelNumber = @(-1);
    }
    return self;
}

- (void)activateWithDelegate:(id<RMQConnectionDelegate>)delegate {
    self.delegate = delegate;
}
- (void)open {}
- (void)blockingClose {}

- (void)basicConsume:(NSString *)queueName
             options:(RMQBasicConsumeOptions)options
            consumer:(void (^)(RMQMessage * _Nonnull))consumer {
    NSError *error = [NSError errorWithDomain:RMQErrorDomain code:RMQChannelErrorUnallocated userInfo:@{NSLocalizedDescriptionKey: @"Unallocated channel"}];
    [self.delegate channel:self error:error];
}

- (void)basicPublish:(NSString *)message
          routingKey:(NSString *)routingKey
            exchange:(NSString *)exchange
          persistent:(BOOL)isPersistent {
}

- (void)basicGet:(NSString *)queue options:(RMQBasicGetOptions)options completionHandler:(void (^)(RMQMessage * _Nonnull))completionHandler {
}

- (RMQExchange *)defaultExchange {
    return nil;
}
- (RMQQueue *)queue:(NSString *)queueName options:(RMQQueueDeclareOptions)options {
    return nil;
}
- (RMQQueue *)queue:(NSString *)queueName {
    return nil;
}
- (void)queueBind:(NSString *)queueName exchange:(NSString *)exchangeName routingKey:(nonnull NSString *)routingKey {
}
- (void)queueUnbind:(NSString *)queueName exchange:(NSString *)exchangeName routingKey:(NSString *)routingKey {
}
- (RMQQueueDeclareOk *)queueDeclare:(NSString *)queueName
                            options:(RMQQueueDeclareOptions)options {
    return nil;
}
- (void)handleFrameset:(RMQFrameset *)frameset {
}
- (void)basicQos:(NSNumber *)count
          global:(BOOL)isGlobal {
}
- (void)ack:(NSNumber *)deliveryTag options:(RMQBasicAckOptions)options {
}
- (void)ack:(NSNumber *)deliveryTag {
}
- (void)reject:(NSNumber *)deliveryTag options:(RMQBasicRejectOptions)options {
}
- (void)reject:(NSNumber *)deliveryTag {
}
- (void)nack:(NSNumber *)deliveryTag options:(RMQBasicNackOptions)options {
}
- (void)nack:(NSNumber *)deliveryTag {
}
- (void)exchangeDeclare:(NSString *)name type:(NSString *)type options:(RMQExchangeDeclareOptions)options {
}
- (RMQExchange *)fanout:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    return nil;
}
@end
