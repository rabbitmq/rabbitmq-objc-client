#import <Foundation/Foundation.h>
#import "RMQMethods.h"
#import "RMQBasicProperties.h"

@protocol RMQChannel;

@interface RMQExchange : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) RMQExchangeDeclareOptions options;

- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                     options:(RMQExchangeDeclareOptions)options
                     channel:(id<RMQChannel>)channel;

- (void)bind:(RMQExchange *)source routingKey:(NSString *)routingKey;
- (void)bind:(RMQExchange *)source;
- (void)unbind:(RMQExchange *)source routingKey:(NSString *)routingKey;
- (void)unbind:(RMQExchange *)source;
- (void)delete:(RMQExchangeDeleteOptions)options;
- (void)delete;
- (void)publish:(NSString *)message
     routingKey:(NSString *)routingKey
     properties:(NSArray <RMQValue<RMQBasicValue> *> *)properties
        options:(RMQBasicPublishOptions)options;
- (void)publish:(NSString *)message
     routingKey:(NSString *)key
     persistent:(BOOL)isPersistent
        options:(RMQBasicPublishOptions)options;
- (void)publish:(NSString *)message
     routingKey:(NSString *)key
     persistent:(BOOL)isPersistent;
- (void)publish:(NSString *)message
     routingKey:(NSString *)key;
- (void)publish:(NSString *)message;

@end
