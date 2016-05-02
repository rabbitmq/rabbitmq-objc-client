#import "RMQSemaphoreWaiter.h"

@interface RMQSemaphoreWaiter ()
@property (nonatomic, readwrite) NSNumber *timeoutSeconds;
@property (nonatomic, readwrite) dispatch_semaphore_t semaphore;
@end

@implementation RMQSemaphoreWaiter

- (instancetype)initWithTimeout:(NSNumber *)timeoutSeconds {
    self = [super init];
    if (self) {
        self.timeoutSeconds = timeoutSeconds;
        self.semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)done {
    dispatch_semaphore_signal(self.semaphore);
}

- (BOOL)timesOut {
    return dispatch_semaphore_wait(self.semaphore, self.syncTimeoutFromNow) != 0;
}

# pragma mark - Private

- (dispatch_time_t)syncTimeoutFromNow {
    return dispatch_time(DISPATCH_TIME_NOW, self.timeoutSeconds.doubleValue * NSEC_PER_SEC);
}

@end
