#import "RMQGCDSerialQueue.h"
#import <libkern/OSAtomic.h>

typedef NS_ENUM(int32_t, RMQGCDSerialQueueStatus) {
    RMQGCDSerialQueueStatusNormal = 1,
    RMQGCDSerialQueueStatusSuspended,
};

@interface RMQGCDSerialQueue ()
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) dispatch_queue_t dispatchQueue;
@property (atomic, readwrite) volatile int32_t status;
@end

@implementation RMQGCDSerialQueue

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
        self.status = RMQGCDSerialQueueStatusNormal;
        NSString *qName = [NSString stringWithFormat:@"RMQGCDSerialQueue (%@)", name];
        self.dispatchQueue = dispatch_queue_create([qName cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    [self resume];
}

- (void)enqueue:(RMQOperation)operation {
    dispatch_async(self.dispatchQueue, operation);
}

- (void)blockingEnqueue:(RMQOperation)operation {
    dispatch_sync(self.dispatchQueue, operation);
}

- (void)delayedBy:(NSNumber *)delay
          enqueue:(RMQOperation)operation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay.doubleValue * NSEC_PER_SEC)),
                   self.dispatchQueue,
                   operation);
}

- (void)suspend {
    if (self.status == RMQGCDSerialQueueStatusSuspended) {
        return;
    }
    while (true) {
        if (OSAtomicCompareAndSwap32(self.status,
                                     RMQGCDSerialQueueStatusSuspended,
                                     &_status)) {
            dispatch_suspend(self.dispatchQueue);
            return;
        }
    }
}

- (void)resume {
    if (self.status == RMQGCDSerialQueueStatusNormal) {
        return;
    }
    while (true) {
        if (OSAtomicCompareAndSwap32(self.status,
                                     RMQGCDSerialQueueStatusNormal,
                                     &_status)) {
            dispatch_resume(self.dispatchQueue);
            return;
        }
    }
}

@end
