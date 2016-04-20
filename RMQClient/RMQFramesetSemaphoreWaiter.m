#import "RMQConstants.h"
#import "RMQFramesetSemaphoreWaiter.h"
#import "RMQChannel.h"

@interface RMQFramesetSemaphoreWaiter ()
@property (nonatomic, readwrite) RMQFrameset *lastFrameset;
@property (nonatomic, readwrite) RMQFramesetWaitResult *result;
@property (nonatomic, readwrite) dispatch_semaphore_t semaphore;
@property (nonatomic, readwrite) NSNumber *syncTimeout;
@end

@implementation RMQFramesetSemaphoreWaiter

- (instancetype)initWithSyncTimeout:(NSNumber *)syncTimeout {
    self = [super init];
    if (self) {
        self.syncTimeout = syncTimeout;
        self.semaphore = dispatch_semaphore_create(0);
        self.lastFrameset = nil;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (RMQFramesetWaitResult *)waitOn:(Class)methodClass {
    RMQFramesetWaitResult *result;
    if (dispatch_semaphore_wait(self.semaphore, self.syncTimeoutFromNow) != 0) {
        NSString *msg = [NSString stringWithFormat:@"Timed out waiting for %@.", methodClass];
        NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                             code:RMQChannelErrorWaitTimeout
                                         userInfo:@{NSLocalizedDescriptionKey: msg}];
        result = [[RMQFramesetWaitResult alloc] initWithFrameset:nil error:error];
    } else if (![self.lastFrameset.method isKindOfClass:methodClass]) {
        NSString *msg = [NSString stringWithFormat:@"Expected %@, got %@.", methodClass, [self.lastFrameset.method class]];
        NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                             code:RMQChannelErrorIncorrectSyncMethod
                                         userInfo:@{NSLocalizedDescriptionKey: msg}];
        result = [[RMQFramesetWaitResult alloc] initWithFrameset:self.lastFrameset error:error];
    } else {
        result = [[RMQFramesetWaitResult alloc] initWithFrameset:self.lastFrameset error:nil];
    }
    return result;
}

- (void)fulfill:(RMQFrameset *)frameset {
    self.lastFrameset = frameset;
    dispatch_semaphore_signal(self.semaphore);
}

- (dispatch_time_t)syncTimeoutFromNow {
    return dispatch_time(DISPATCH_TIME_NOW, self.syncTimeout.doubleValue * NSEC_PER_SEC);
}

@end
