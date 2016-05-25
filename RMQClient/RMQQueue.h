#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQMessage.h"
#import "RMQExchange.h"
#import "RMQConsumer.h"
#import "RMQConsumerDeliveryHandler.h"
#import "RMQBasicProperties.h"

@protocol RMQChannel;

@interface RMQQueue : NSObject
@property (copy, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) RMQQueueDeclareOptions options;

- (instancetype)initWithName:(NSString *)name
                     options:(RMQQueueDeclareOptions)options
                     channel:(id <RMQChannel>)channel;

- (instancetype)initWithName:(NSString *)name
                     channel:(id <RMQChannel>)channel;

- (void)bind:(RMQExchange *)exchange routingKey:(NSString *)routingKey;
- (void)bind:(RMQExchange *)exchange;
- (void)unbind:(RMQExchange *)exchange routingKey:(NSString *)routingKey;
- (void)unbind:(RMQExchange *)exchange;
- (void)delete:(RMQQueueDeleteOptions)options;
- (void)delete;
- (void)publish:(NSString *)message
     properties:(NSArray <RMQValue<RMQBasicValue> *> *)properties
        options:(RMQBasicPublishOptions)options;
- (void)publish:(NSString *)message
     persistent:(BOOL)isPersistent
        options:(RMQBasicPublishOptions)options;
- (void)publish:(NSString *)message
     persistent:(BOOL)isPersistent;
- (void)publish:(NSString *)message;
- (void)pop:(RMQConsumerDeliveryHandler)handler;
- (RMQConsumer *)subscribe:(RMQConsumerDeliveryHandler)handler;
- (RMQConsumer *)subscribe:(RMQBasicConsumeOptions)options
                   handler:(RMQConsumerDeliveryHandler)handler;

@end
