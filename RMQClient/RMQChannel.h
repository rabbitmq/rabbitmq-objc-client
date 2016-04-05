#import <Foundation/Foundation.h>
#import "AMQMethods.h"
#import "RMQExchange.h"
#import "RMQFrameHandler.h"
#import "RMQQueue.h"

@protocol RMQChannel <NSObject, RMQFrameHandler>

@property (nonnull, copy, nonatomic, readonly) NSNumber *channelNumber;
@property (nonnull, nonatomic, readonly) NSNumber *prefetchCount;
@property (nonatomic, readonly) BOOL prefetchGlobal;

- (nonnull RMQExchange *)defaultExchange;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(AMQQueueDeclareOptions)options;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName;

- (nonnull AMQQueueDeclareOk *)queueDeclare:(nonnull NSString *)queueName
                                    options:(AMQQueueDeclareOptions)options;

- (void)basicConsume:(nonnull NSString *)queueName
             options:(AMQBasicConsumeOptions)options
            consumer:(void (^ _Nonnull)(id <RMQMessage> _Nonnull))consumer;

- (nullable AMQBasicQosOk *)basicQos:(nonnull NSNumber *)count
                              global:(BOOL)isGlobal
                               error:(NSError * _Nullable * _Nullable)error;

@end
