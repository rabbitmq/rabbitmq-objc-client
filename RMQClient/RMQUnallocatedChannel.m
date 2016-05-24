#import "RMQUnallocatedChannel.h"
#import "RMQErrors.h"
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

- (void)close {}

- (void)blockingClose {}

- (void)recover {}

- (void)blockingWaitOn:(Class)method {
    [self err];
}

- (RMQConsumer *)basicConsume:(NSString *)queueName
                      options:(RMQBasicConsumeOptions)options
                      handler:(RMQConsumerDeliveryHandler)handler {
    [self err];
    return nil;
}

- (void)basicCancel:(NSString *)consumerTag {
}

- (void)basicPublish:(NSString *)message
          routingKey:(NSString *)routingKey
            exchange:(NSString *)exchange
          properties:(NSArray *)properties
             options:(RMQBasicPublishOptions)options {
    [self err];
}

-  (void)basicGet:(NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(RMQConsumerDeliveryHandler)completionHandler {
    [self err];
}

- (RMQExchange *)defaultExchange {
    [self err];
    return nil;
}

- (RMQQueue *)queue:(NSString *)queueName options:(RMQQueueDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQQueue *)queue:(NSString *)queueName {
    return [self queue:queueName options:RMQQueueDeclareNoOptions];
}

- (void)queueDelete:(NSString *)queueName
            options:(RMQQueueDeleteOptions)options {
    [self err];
}

- (void)queueBind:(NSString *)queueName exchange:(NSString *)exchangeName routingKey:(nonnull NSString *)routingKey {
    [self err];
}

- (void)queueUnbind:(NSString *)queueName exchange:(NSString *)exchangeName routingKey:(NSString *)routingKey {
    [self err];
}

- (void)handleFrameset:(RMQFrameset *)frameset {
}

- (void)basicQos:(NSNumber *)count
          global:(BOOL)isGlobal {
    [self err];
}

- (void)ack:(NSNumber *)deliveryTag options:(RMQBasicAckOptions)options {
    [self err];
}

- (void)ack:(NSNumber *)deliveryTag {
    [self ack:deliveryTag options:RMQBasicAckNoOptions];
}

- (void)reject:(NSNumber *)deliveryTag options:(RMQBasicRejectOptions)options {
    [self err];
}

- (void)reject:(NSNumber *)deliveryTag {
    [self reject:deliveryTag options:RMQBasicRejectNoOptions];
}

- (void)nack:(NSNumber *)deliveryTag options:(RMQBasicNackOptions)options {
    [self err];
}

- (void)nack:(NSNumber *)deliveryTag {
    [self nack:deliveryTag options:RMQBasicNackNoOptions];
}

- (void)exchangeDeclare:(NSString *)name type:(NSString *)type options:(RMQExchangeDeclareOptions)options {
    [self err];
}

- (void)exchangeBind:(NSString *)sourceName
         destination:(NSString *)destinationName
          routingKey:(NSString *)routingKey {
    [self err];
}

- (void)exchangeUnbind:(NSString *)sourceName
           destination:(NSString *)destinationName
            routingKey:(NSString *)routingKey {
    [self err];
}

- (RMQExchange *)fanout:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)fanout:(NSString *)name {
    return [self fanout:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)direct:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)direct:(NSString *)name {
    return [self direct:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)topic:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)topic:(NSString *)name {
    return [self topic:name options:RMQExchangeDeclareNoOptions];
}

- (RMQExchange *)headers:(NSString *)name options:(RMQExchangeDeclareOptions)options {
    [self err];
    return nil;
}

- (RMQExchange *)headers:(NSString *)name {
    return [self headers:name options:RMQExchangeDeclareNoOptions];
}

- (void)exchangeDelete:(NSString *)name
               options:(RMQExchangeDeleteOptions)options {
    [self err];
}

# pragma mark - Private

- (void)err {
    NSError *error = [NSError errorWithDomain:RMQErrorDomain code:RMQErrorChannelUnallocated userInfo:@{NSLocalizedDescriptionKey: @"Unallocated channel"}];
    [self.delegate channel:self error:error];
}

@end
