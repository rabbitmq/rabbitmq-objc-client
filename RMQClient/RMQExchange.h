#import <Foundation/Foundation.h>

@interface RMQExchange : NSObject
- (void)publish:(NSString *)message routingKey:(NSString *)key;
@end
