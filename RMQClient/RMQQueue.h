#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQMessage.h"
#import "RMQExchange.h"
#import "RMQConsumerDeliveryHandler.h"

@protocol RMQChannel;

@interface RMQQueue : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             options:(RMQQueueDeclareOptions)options
                             channel:(nonnull id <RMQChannel>)channel;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             channel:(nonnull id <RMQChannel>)channel;

- (void)bind:(nonnull RMQExchange *)exchange routingKey:(nonnull NSString *)routingKey;
- (void)bind:(nonnull RMQExchange *)exchange;
- (void)unbind:(nonnull RMQExchange *)exchange routingKey:(nonnull NSString *)routingKey;
- (void)unbind:(nonnull RMQExchange *)exchange;
- (void)delete:(RMQQueueDeleteOptions)options;
- (void)delete;
- (void)publish:(nonnull NSString *)message persistent:(BOOL)isPersistent;
- (void)publish:(nonnull NSString *)message;
- (void)pop:(RMQConsumerDeliveryHandler _Nonnull)handler;
- (void)subscribe:(RMQConsumerDeliveryHandler _Nonnull)handler;
- (void)subscribe:(RMQBasicConsumeOptions)options
          handler:(RMQConsumerDeliveryHandler _Nonnull)handler;

@end
