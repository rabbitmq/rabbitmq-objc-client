#import "RMQChannel.h"

@implementation RMQChannel
- (RMQQueue *)queue:(NSString *)queueName
         autoDelete:(BOOL)shouldAutoDelete
          exclusive:(BOOL)isExclusive {
    return [RMQQueue new];
}
- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}
- (void)close {
    
}
- (BOOL)isOpen {
    return YES;
}
@end
