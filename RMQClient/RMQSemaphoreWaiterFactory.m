#import "RMQSemaphoreWaiterFactory.h"
#import "RMQSemaphoreWaiter.h"
#import "RMQFramesetSemaphoreWaiter.h"

@implementation RMQSemaphoreWaiterFactory

- (id)makeWithTimeout:(NSNumber *)timeoutSeconds {
    return [[RMQSemaphoreWaiter alloc] initWithTimeout:timeoutSeconds];
}

- (id<RMQFramesetWaiter>)makeFramesetWaiterWithTimeout:(NSNumber *)timeoutSeconds {
    return [[RMQFramesetSemaphoreWaiter alloc] initWithSyncTimeout:timeoutSeconds];
}

@end
