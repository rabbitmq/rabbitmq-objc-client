#import <Foundation/Foundation.h>
#import "AMQMethods.h"
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
                    options:(AMQQueueDeclareOptions)options;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName;

- (void)basicConsume:(nonnull NSString *)queueName
             options:(AMQBasicConsumeOptions)options
            consumer:(void (^ _Nonnull)(id <RMQMessage> _Nonnull))consumer;

- (void)basicPublish:(nonnull NSString *)message
          routingKey:(nonnull NSString *)routingKey
            exchange:(nonnull NSString *)exchange;

-  (void)basicGet:(nonnull NSString *)queue
          options:(AMQBasicGetOptions)options
completionHandler:(void (^ _Nonnull)(id<RMQMessage> _Nonnull message))completionHandler;

- (void)basicQos:(nonnull NSNumber *)count
          global:(BOOL)isGlobal;

- (void)ack:(nonnull NSNumber *)deliveryTag
    options:(AMQBasicAckOptions)options;

- (void)ack:(nonnull NSNumber *)deliveryTag;

- (void)reject:(nonnull NSNumber *)deliveryTag
       options:(AMQBasicRejectOptions)options;

- (void)reject:(nonnull NSNumber *)deliveryTag;

- (void)nack:(nonnull NSNumber *)deliveryTag
     options:(AMQBasicNackOptions)options;

- (void)nack:(nonnull NSNumber *)deliveryTag;

@end
