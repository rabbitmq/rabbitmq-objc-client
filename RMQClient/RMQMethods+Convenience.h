#import "RMQMethods.h"

@interface RMQBasicConsume (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                  consumerTag:(NSString *)consumerTag
                      options:(RMQBasicConsumeOptions)options;

@end

@interface RMQBasicQos (Convenience)

- (instancetype)initWithPrefetchCount:(NSNumber *)prefetchCount
                               global:(BOOL)isGlobal;

@end

@interface RMQChannelOpen (Convenience)
@end

@interface RMQChannelClose (Convenience)
@end

@interface RMQConfirmSelect (Convenience)
@end

@interface RMQExchangeBind (Convenience)

- (instancetype)initWithDestination:(NSString *)destination
                             source:(NSString *)source
                         routingKey:(NSString *)routingKey;

@end

@interface RMQExchangeDeclare (Convenience)

- (instancetype)initWithExchange:(NSString *)exchangeName
                            type:(NSString *)type
                         options:(RMQExchangeDeclareOptions)options;

@end

@interface RMQExchangeUnbind (Convenience)

- (instancetype)initWithDestination:(NSString *)destination
                             source:(NSString *)source
                         routingKey:(NSString *)routingKey;

@end

@interface RMQQueueBind (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                     exchange:(NSString *)exchangeName
                   routingKey:(NSString *)routingKey;

@end

@interface RMQQueueDeclare (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                      options:(RMQQueueDeclareOptions)options
                    arguments:(RMQTable *)arguments;

@end

@interface RMQQueueDelete (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                      options:(RMQQueueDeleteOptions)options;

@end

@interface RMQQueueUnbind (Convenience)

- (instancetype)initWithQueue:(NSString *)queueName
                     exchange:(NSString *)exchangeName
                   routingKey:(NSString *)routingKey;

@end
