#import "RMQSemaphoreWaiterFactory.h"
#import "RMQSemaphoreWaiter.h"

@implementation RMQSemaphoreWaiterFactory

- (id)makeWithTimeout:(NSNumber *)timeoutSeconds {
    return [[RMQSemaphoreWaiter alloc] initWithTimeout:timeoutSeconds];
}

@end
