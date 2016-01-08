#import "RMQChannel.h"

@implementation RMQChannel
- (RMQQueue *)queue:(NSString *)queueName autoDelete:(BOOL)shouldAutoDelete {
    return [RMQQueue new];
}
- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}
@end
