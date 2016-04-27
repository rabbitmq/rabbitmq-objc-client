#import "RMQGCDHeartbeatSender.h"
#import "RMQHeartbeat.h"

@interface RMQGCDHeartbeatSender ()
@property (nonatomic, readwrite) id<RMQTransport> transport;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> queue;
@property (nonatomic, readwrite) id<RMQWaiterFactory> waiterFactory;
@property (nonatomic, readwrite) id<RMQClock> clock;
@property (nonatomic, readwrite) BOOL active;
@property (nonatomic, readwrite) NSDate *lastBeatAt;
@end

@implementation RMQGCDHeartbeatSender

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                            queue:(id<RMQLocalSerialQueue>)queue
                    waiterFactory:(id<RMQWaiterFactory>)waiterFactory
                            clock:(id<RMQClock>)clock {
    self = [super init];
    if (self) {
        self.active = NO;
        self.transport = transport;
        self.queue = queue;
        self.waiterFactory = waiterFactory;
        self.clock = clock;
        [self signalActivity];
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)startWithInterval:(NSNumber *)intervalSeconds {
    self.active = YES;
    [self beatAfterInterval:intervalSeconds];
}

- (void)stop {
    self.active = NO;
}

- (void)signalActivity {
    self.lastBeatAt = self.clock.read;
}

# pragma mark - Private

- (void)beatAfterInterval:(NSNumber *)intervalSeconds {
    [self.queue enqueue:^{
        id<RMQWaiter> waiter = [self.waiterFactory makeWithTimeout:intervalSeconds];
        [waiter timesOut];
        if ([self intervalPassed:intervalSeconds]) [self.transport write:self.heartbeatData];
        if (self.active)                           [self beatAfterInterval:intervalSeconds];
    }];
}

- (BOOL)intervalPassed:(NSNumber *)intervalSeconds {
    return [self.clock.read timeIntervalSinceDate:self.lastBeatAt] > intervalSeconds.doubleValue;
}

- (NSData *)heartbeatData {
    return [RMQHeartbeat new].amqEncoded;
}

@end
