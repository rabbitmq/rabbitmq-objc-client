#import <Foundation/Foundation.h>

@protocol RMQChannel;

@interface RMQExchange : NSObject

- (instancetype)initWithChannel:(id<RMQChannel>)channel;

- (void)publish:(NSString *)message routingKey:(NSString *)key persistent:(BOOL)isPersistent;
- (void)publish:(NSString *)message routingKey:(NSString *)key;

@end
