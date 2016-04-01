#import <Foundation/Foundation.h>
#import "AMQMethods.h"
#import "RMQExchange.h"
#import "RMQFrameHandler.h"
#import "RMQQueue.h"

@protocol RMQChannel <NSObject, RMQFrameHandler>

@property (nonnull, copy, nonatomic, readonly) NSNumber *channelNumber;

- (nonnull RMQExchange *)defaultExchange;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName
                    options:(AMQQueueDeclareOptions)options;

- (nonnull RMQQueue *)queue:(nonnull NSString *)queueName;

- (nonnull AMQQueueDeclareOk *)queueDeclare:(nonnull NSString *)queueName
                                    options:(AMQQueueDeclareOptions)options;

- (void)basicConsume:(nonnull NSString *)queueName
            consumer:(void (^ _Nonnull)(id <RMQMessage> _Nonnull))consumer;

@end
