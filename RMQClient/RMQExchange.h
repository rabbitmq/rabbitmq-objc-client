#import <Foundation/Foundation.h>

@protocol RMQChannel;

@interface RMQExchange : NSObject

- (instancetype)initWithName:(NSString *)name
                     channel:(id<RMQChannel>)channel;

- (void)publish:(NSString *)message routingKey:(NSString *)key persistent:(BOOL)isPersistent;
- (void)publish:(NSString *)message routingKey:(NSString *)key;
- (void)publish:(NSString *)message;

@end
