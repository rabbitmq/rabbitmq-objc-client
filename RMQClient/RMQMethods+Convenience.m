#import "RMQMethods+Convenience.h"

@implementation RMQBasicConsume (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                  consumerTag:(NSString *)consumerTag
                      options:(RMQBasicConsumeOptions)options {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                       consumerTag:[[RMQShortstr alloc] init:consumerTag]
                           options:options
                         arguments:[RMQTable new]];
}

@end

@implementation RMQBasicQos (Convenience)

- (instancetype)initWithPrefetchCount:(NSNumber *)prefetchCount
                               global:(BOOL)isGlobal {
    RMQBasicQosOptions options = RMQBasicQosNoOptions;
    if (isGlobal) options     |= RMQBasicQosGlobal;

    return [self initWithPrefetchSize:[[RMQLong alloc] init:0]
                        prefetchCount:[[RMQShort alloc] init:prefetchCount.integerValue]
                              options:options];
}

@end

@implementation RMQChannelOpen (Convenience)

- (instancetype)init {
    return [self initWithReserved1:[[RMQShortstr alloc] init:@""]];
}

@end

@implementation RMQChannelClose (Convenience)

- (instancetype)init {
    return [self initWithReplyCode:[[RMQShort alloc] init:200]
                         replyText:[[RMQShortstr alloc] init:@"Goodbye"]
                           classId:[[RMQShort alloc] init:0]
                          methodId:[[RMQShort alloc] init:0]];
}

@end

@implementation RMQConfirmSelect (Convenience)

- (instancetype)init {
    return [self initWithOptions:RMQConfirmSelectNoOptions];
}

@end

@implementation RMQExchangeBind (Convenience)

- (instancetype)initWithDestination:(NSString *)destination
                             source:(NSString *)source
                         routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                       destination:[[RMQShortstr alloc] init:destination]
                            source:[[RMQShortstr alloc] init:source]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                           options:RMQExchangeBindNoOptions
                         arguments:[RMQTable new]];
}

@end

@implementation RMQExchangeDeclare (Convenience)

- (instancetype)initWithExchange:(NSString *)exchangeName
                            type:(NSString *)type
                         options:(RMQExchangeDeclareOptions)options {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                          exchange:[[RMQShortstr alloc] init:exchangeName]
                              type:[[RMQShortstr alloc] init:type]
                           options:options
                         arguments:[RMQTable new]];
}

@end

@implementation RMQExchangeUnbind (Convenience)

- (instancetype)initWithDestination:(NSString *)destination
                             source:(NSString *)source
                         routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                       destination:[[RMQShortstr alloc] init:destination]
                            source:[[RMQShortstr alloc] init:source]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                           options:RMQExchangeUnbindNoOptions
                         arguments:[RMQTable new]];
}

@end

@implementation RMQQueueBind (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                     exchange:(NSString *)exchangeName
                   routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                          exchange:[[RMQShortstr alloc] init:exchangeName]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                           options:RMQQueueBindNoOptions
                         arguments:[RMQTable new]];
}

@end

@implementation RMQQueueDeclare (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                      options:(RMQQueueDeclareOptions)options
                    arguments:(RMQTable *)arguments {
    RMQShort *ticket          = [[RMQShort alloc] init:0];
    RMQShortstr *amqQueueName = [[RMQShortstr alloc] init:queueName];

    return [self initWithReserved1:ticket
                             queue:amqQueueName
                           options:options
                         arguments:arguments];
}

@end

@implementation RMQQueueDelete (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                      options:(RMQQueueDeleteOptions)options {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                           options:options];
}

@end

@implementation RMQQueueUnbind (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                     exchange:(NSString *)exchangeName
                   routingKey:(NSString *)routingKey {
    return [self initWithReserved1:[[RMQShort alloc] init:0]
                             queue:[[RMQShortstr alloc] init:queueName]
                          exchange:[[RMQShortstr alloc] init:exchangeName]
                        routingKey:[[RMQShortstr alloc] init:routingKey]
                         arguments:[RMQTable new]];
}

@end
