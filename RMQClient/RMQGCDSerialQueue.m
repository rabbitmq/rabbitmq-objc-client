#import "RMQGCDSerialQueue.h"

@interface RMQGCDSerialQueue ()
@property (nonatomic, readwrite) dispatch_queue_t dispatchQueue;
@end

@implementation RMQGCDSerialQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dispatchQueue = dispatch_queue_create("RMQGCDSerialQueue", NULL);
    }
    return self;
}

- (void)enqueue:(void (^)())operation {
    dispatch_async(self.dispatchQueue, operation);
}

- (void)blockingEnqueue:(void (^)())operation {
    dispatch_sync(self.dispatchQueue, operation);
}

- (void)suspend {
    dispatch_suspend(self.dispatchQueue);
}

- (void)resume {
    dispatch_resume(self.dispatchQueue);
}

@end
