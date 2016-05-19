#import <Foundation/Foundation.h>
#import "RMQConsumerDeliveryHandler.h"
#import "RMQMethods.h"

@protocol RMQChannel;

@interface RMQConsumer : NSObject

@property (nonatomic, readonly) NSString *queueName;
@property (nonatomic, readonly) RMQBasicConsumeOptions options;
@property (nonatomic, readonly) NSString *tag;
@property (nonatomic, readonly) RMQConsumerDeliveryHandler handler;

- (instancetype)initWithQueueName:(NSString *)queueName
                          options:(RMQBasicConsumeOptions)options
                      consumerTag:(NSString *)tag
                          handler:(RMQConsumerDeliveryHandler)handler
                          channel:(id<RMQChannel>)channel;
- (void)cancel;

@end
