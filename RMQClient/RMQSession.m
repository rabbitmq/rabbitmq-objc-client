#import "RMQSession.h"

@implementation RMQSession
- (void)start {
    
}
- (RMQChannel *)createChannel {
    return [RMQChannel new];
}
@end
