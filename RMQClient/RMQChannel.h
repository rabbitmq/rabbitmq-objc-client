#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQExchange.h"
#import "RMQFrameHandler.h"
#import "RMQQueue.h"

@protocol RMQConnectionDelegate;

@protocol RMQChannel <NSObject, RMQFrameHandler>

@property (nonnull, copy, nonatomic, readonly) NSNumber *channelNumber;

- (void)activateWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;
- (void)open;
- (void)close;
- (void)blockingClose;
- (void)recover;
- (void)blockingWaitOn:(nonnull Class)method;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(RMQQueueDeclareOptions)options;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName;

- (void)queueDelete:(nonnull NSString *)queueName
            options:(RMQQueueDeleteOptions)options;

- (void)queueBind:(nonnull NSString *)queueName
         exchange:(nonnull NSString *)exchangeName
       routingKey:(nonnull NSString *)routingKey;

- (void)queueUnbind:(nonnull NSString *)queueName
           exchange:(nonnull NSString *)exchangeName
         routingKey:(nonnull NSString *)routingKey;

- (nonnull RMQConsumer *)basicConsume:(nonnull NSString *)queueName
                              options:(RMQBasicConsumeOptions)options
                              handler:(RMQConsumerDeliveryHandler _Nonnull)handler;

- (void)basicCancel:(nonnull NSString *)consumerTag;

- (void)basicPublish:(nonnull NSString *)message
          routingKey:(nonnull NSString *)routingKey
            exchange:(nonnull NSString *)exchange
          properties:(nonnull NSArray<RMQValue *> *)properties
             options:(RMQBasicPublishOptions)options;

-  (void)basicGet:(nonnull NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(RMQConsumerDeliveryHandler _Nonnull)completionHandler;

- (void)basicQos:(nonnull NSNumber *)count
          global:(BOOL)isGlobal;

- (void)ack:(nonnull NSNumber *)deliveryTag
    options:(RMQBasicAckOptions)options;

- (void)ack:(nonnull NSNumber *)deliveryTag;

- (void)reject:(nonnull NSNumber *)deliveryTag
       options:(RMQBasicRejectOptions)options;

- (void)reject:(nonnull NSNumber *)deliveryTag;

- (void)nack:(nonnull NSNumber *)deliveryTag
     options:(RMQBasicNackOptions)options;

- (void)nack:(nonnull NSNumber *)deliveryTag;

- (nonnull RMQExchange *)defaultExchange;

- (nonnull RMQExchange *)fanout:(nonnull NSString *)name
                        options:(RMQExchangeDeclareOptions)options;

- (nonnull RMQExchange *)fanout:(nonnull NSString *)name;

- (nonnull RMQExchange *)direct:(nonnull NSString *)name
                        options:(RMQExchangeDeclareOptions)options;

- (nonnull RMQExchange *)direct:(nonnull NSString *)name;

- (nonnull RMQExchange *)topic:(nonnull NSString *)name
                       options:(RMQExchangeDeclareOptions)options;

- (nonnull RMQExchange *)topic:(nonnull NSString *)name;

- (nonnull RMQExchange *)headers:(nonnull NSString *)name
                         options:(RMQExchangeDeclareOptions)options;
- (nonnull RMQExchange *)headers:(nonnull NSString *)name;

- (void)exchangeDeclare:(nonnull NSString *)name
                   type:(nonnull NSString *)type
                options:(RMQExchangeDeclareOptions)options;

- (void)exchangeBind:(nonnull NSString *)sourceName
         destination:(nonnull NSString *)destinationName
          routingKey:(nonnull NSString *)routingKey;

- (void)exchangeUnbind:(nonnull NSString *)sourceName
           destination:(nonnull NSString *)destinationName
            routingKey:(nonnull NSString *)routingKey;

- (void)exchangeDelete:(nonnull NSString *)name
               options:(RMQExchangeDeleteOptions)options;

@end
