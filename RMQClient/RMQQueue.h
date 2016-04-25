#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQMessage.h"
#import "RMQSender.h"
#import "RMQExchange.h"
#import "RMQConsumer.h"

@protocol RMQChannel;

@interface RMQQueue : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             options:(RMQQueueDeclareOptions)options
                             channel:(nonnull id <RMQChannel>)channel
                              sender:(nonnull id <RMQSender>)sender;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             channel:(nonnull id <RMQChannel>)channel
                              sender:(nonnull id <RMQSender>)sender;

- (void)bind:(nonnull RMQExchange *)exchange routingKey:(nonnull NSString *)routingKey;
- (void)bind:(nonnull RMQExchange *)exchange;
- (void)publish:(nonnull NSString *)message persistent:(BOOL)isPersistent;
- (void)publish:(nonnull NSString *)message;
- (void)pop:(RMQConsumer _Nonnull)handler;
- (void)subscribe:(RMQConsumer _Nonnull)handler;
- (void)subscribe:(RMQBasicConsumeOptions)options
          handler:(RMQConsumer _Nonnull)handler;

@end
