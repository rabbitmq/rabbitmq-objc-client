#import "RMQConnectionRecover.h"

@interface RMQConnectionRecover ()
@property (nonatomic, readwrite) NSNumber *interval;
@property (nonatomic, readwrite) NSUInteger attempts;
@property (nonatomic, readwrite) NSUInteger attemptLimit;
@property (nonatomic, readwrite) BOOL onlyErrors;
@property (nonatomic, readwrite) id<RMQHeartbeatSender> heartbeatSender;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@end

@implementation RMQConnectionRecover

- (instancetype)initWithInterval:(NSNumber *)interval
                    attemptLimit:(NSNumber *)attemptLimit
                      onlyErrors:(BOOL)onlyErrors
                 heartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender
                    commandQueue:(id<RMQLocalSerialQueue>)commandQueue
                        delegate:(id<RMQConnectionDelegate>)delegate {
    self = [super init];
    if (self) {
        self.interval = interval;
        self.attempts = 0;
        self.onlyErrors = onlyErrors;
        self.attemptLimit = attemptLimit.integerValue;
        self.heartbeatSender = heartbeatSender;
        self.commandQueue = commandQueue;
        self.delegate = delegate;
    }
    return self;
}

-  (void)recover:(id<RMQStarter>)connection
channelAllocator:(id<RMQChannelAllocator>)allocator
           error:(NSError *)error {
    [self.commandQueue enqueue:^{
        [self.heartbeatSender stop];
    }];

    if ((self.onlyErrors && !error) || [self currentAttemptBeyondLimit]) {
        return;
    }

    [self.delegate willStartRecoveryWithConnection:(RMQConnection *)connection];
    [self.commandQueue delayedBy:self.interval enqueue:^{
        [self.delegate startingRecoveryWithConnection:(RMQConnection *)connection];
        [connection start:^{
            [self.commandQueue enqueue:^{
                for (id<RMQChannel> ch in allocator.allocatedUserChannels) {
                    [ch recover];
                }
                self.attempts = 0;
                [self.delegate recoveredConnection:(RMQConnection *)connection];
            }];
        }];
    }];
}

# pragma mark - Private

- (BOOL)currentAttemptBeyondLimit {
    return self.interval.integerValue == 0 || ++self.attempts > self.attemptLimit;
}

@end
