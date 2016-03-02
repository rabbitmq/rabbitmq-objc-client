#import "RMQChannel1Allocator.h"
#import "RMQDispatchQueueChannel.h"

@implementation RMQChannel1Allocator
- (id<RMQChannel>)allocateWithSender:(id<RMQSender>)sender {
    return [[RMQDispatchQueueChannel alloc] init:@1 sender:sender];
}
@end
