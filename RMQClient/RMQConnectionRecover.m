#import "RMQConnectionRecover.h"

@interface RMQConnectionRecover ()
@property (nonatomic, readwrite) NSNumber *interval;
@property (nonatomic, readwrite) NSUInteger attempts;
@property (nonatomic, readwrite) NSUInteger attemptLimit;
@property (nonatomic, readwrite) id<RMQHeartbeatSender> heartbeatSender;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@end

@implementation RMQConnectionRecover

- (instancetype)initWithInterval:(NSNumber *)interval
                    attemptLimit:(NSNumber *)attemptLimit
                 heartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender
                    commandQueue:(id<RMQLocalSerialQueue>)commandQueue
                        delegate:(id<RMQConnectionDelegate>)delegate {
    self = [super init];
    if (self) {
        self.interval = interval;
        self.attempts = 0;
        self.attemptLimit = attemptLimit.integerValue;
        self.heartbeatSender = heartbeatSender;
        self.commandQueue = commandQueue;
        self.delegate = delegate;
    }
    return self;
}

-  (void)recover:(id<RMQStarter>)connection
channelAllocator:(id<RMQChannelAllocator>)allocator {
    if (++self.attempts > self.attemptLimit) return;

    [self.delegate willStartRecoveryWithConnection:(RMQConnection *)connection];
    [self.commandQueue enqueue:^{
        [self.heartbeatSender stop];
    }];
    [self.commandQueue delayedBy:self.interval enqueue:^{
        [self.delegate startingRecoveryWithConnection:(RMQConnection *)connection];
        [connection start:^{
            [self.commandQueue enqueue:^{
                for (id<RMQChannel> ch in allocator.allocatedUserChannels) {
                    [ch recover];
                }
                [self.delegate recoveredConnection:(RMQConnection *)connection];
            }];
        }];
    }];
}

@end
