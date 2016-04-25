#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQExchange.h"
#import "RMQFrameHandler.h"
#import "RMQQueue.h"

@protocol RMQConnectionDelegate;

@protocol RMQChannel <NSObject, RMQFrameHandler>

@property (nonnull, copy, nonatomic, readonly) NSNumber *channelNumber;

- (nonnull RMQExchange *)defaultExchange;

- (void)activateWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;
- (void)open;
- (void)blockingClose;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(RMQQueueDeclareOptions)options;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName;

- (void)queueBind:(nonnull NSString *)queueName
         exchange:(nonnull NSString *)exchangeName
       routingKey:(nonnull NSString *)routingKey;

- (void)queueUnbind:(nonnull NSString *)queueName
           exchange:(nonnull NSString *)exchangeName
         routingKey:(nonnull NSString *)routingKey;

- (void)basicConsume:(nonnull NSString *)queueName
             options:(RMQBasicConsumeOptions)options
            consumer:(void (^ _Nonnull)(RMQMessage * _Nonnull))consumer;

- (void)basicPublish:(nonnull NSString *)message
          routingKey:(nonnull NSString *)routingKey
            exchange:(nonnull NSString *)exchange;

- (void)basicPublish:(nonnull NSString *)message
          routingKey:(nonnull NSString *)routingKey
            exchange:(nonnull NSString *)exchange
          persistent:(BOOL)isPersistent;

-  (void)basicGet:(nonnull NSString *)queue
          options:(RMQBasicGetOptions)options
completionHandler:(void (^ _Nonnull)(RMQMessage * _Nonnull message))completionHandler;

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

- (void)exchangeDeclare:(nonnull NSString *)name
                   type:(nonnull NSString *)type
                options:(RMQExchangeDeclareOptions)options;

- (nonnull RMQExchange *)fanout:(nonnull NSString *)name
                        options:(RMQExchangeDeclareOptions)options;

@end
