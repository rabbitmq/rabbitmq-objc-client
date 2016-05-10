#import "RMQChannel.h"
#import "RMQErrors.h"
#import "RMQFramesetSemaphoreWaiter.h"

@interface RMQFramesetSemaphoreWaiter ()
@property (nonatomic, readwrite) RMQFrameset *lastFrameset;
@property (nonatomic, readwrite) RMQFramesetWaitResult *result;
@end

@implementation RMQFramesetSemaphoreWaiter

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lastFrameset = nil;
    }
    return self;
}

- (RMQFramesetWaitResult *)waitOn:(Class)methodClass {
    RMQFramesetWaitResult *result;
    if (![self.lastFrameset.method isKindOfClass:methodClass]) {
        NSString *msg = [NSString stringWithFormat:@"Expected %@, got %@.", methodClass, [self.lastFrameset.method class]];
        NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                             code:RMQErrorChannelIncorrectSyncMethod
                                         userInfo:@{NSLocalizedDescriptionKey: msg}];
        result = [[RMQFramesetWaitResult alloc] initWithFrameset:self.lastFrameset error:error];
    } else {
        result = [[RMQFramesetWaitResult alloc] initWithFrameset:self.lastFrameset error:nil];
    }
    return result;
}

- (void)fulfill:(RMQFrameset *)frameset {
    self.lastFrameset = frameset;
}

@end
