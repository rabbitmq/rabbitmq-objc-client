#import <Foundation/Foundation.h>
#import "RMQMethods.h"

@protocol RMQChannel;

@interface RMQExchange : NSObject

@property (nonatomic, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name
                     channel:(id<RMQChannel>)channel;

- (void)bind:(RMQExchange *)source routingKey:(NSString *)routingKey;
- (void)bind:(RMQExchange *)source;
- (void)delete:(RMQExchangeDeleteOptions)options;
- (void)delete;
- (void)publish:(NSString *)message routingKey:(NSString *)key persistent:(BOOL)isPersistent;
- (void)publish:(NSString *)message routingKey:(NSString *)key;
- (void)publish:(NSString *)message;

@end
