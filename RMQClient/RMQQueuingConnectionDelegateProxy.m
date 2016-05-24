#import "RMQQueuingConnectionDelegateProxy.h"

@interface RMQQueuingConnectionDelegateProxy ()
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) dispatch_queue_t queue;
@end

@implementation RMQQueuingConnectionDelegateProxy

- (instancetype)initWithDelegate:(id<RMQConnectionDelegate>)delegate
                           queue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.queue = queue;
    }
    return self;
}

- (void)connection:(RMQConnection *)connection disconnectedWithError:(NSError *)error {
    dispatch_async(self.queue, ^{
        [self.delegate connection:connection disconnectedWithError:error];
    });
}

- (void)connection:(RMQConnection *)connection failedToConnectWithError:(NSError *)error {
    dispatch_async(self.queue, ^{
        [self.delegate connection:connection failedToConnectWithError:error];
    });
}

- (void)connection:(RMQConnection *)connection failedToWriteWithError:(NSError *)error {
    dispatch_async(self.queue, ^{
        [self.delegate connection:connection failedToWriteWithError:error];
    });
}

- (void)channel:(id<RMQChannel>)channel error:(NSError *)error {
    dispatch_async(self.queue, ^{
        [self.delegate channel:channel error:error];
    });
}

- (void)willStartRecoveryWithConnection:(RMQConnection *)connection {
    dispatch_async(self.queue, ^{
        [self.delegate willStartRecoveryWithConnection:connection];
    });
}

- (void)startingRecoveryWithConnection:(RMQConnection *)connection {
    dispatch_async(self.queue, ^{
        [self.delegate startingRecoveryWithConnection:connection];
    });
}

- (void)recoveredConnection:(RMQConnection *)connection {
    dispatch_async(self.queue, ^{
        [self.delegate recoveredConnection:connection];
    });
}

@end
