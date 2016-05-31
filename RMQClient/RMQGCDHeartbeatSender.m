#import "RMQGCDHeartbeatSender.h"
#import "RMQHeartbeat.h"

@interface RMQGCDHeartbeatSender ()
@property (nonatomic, readwrite) id<RMQTransport> transport;
@property (nonatomic, readwrite) id<RMQClock> clock;
@property (nonatomic, readwrite) dispatch_source_t timer;
@property (atomic, readwrite) NSDate *lastBeatAt;
@property (nonatomic, readwrite) dispatch_queue_t dispatchQueue;
@end

@implementation RMQGCDHeartbeatSender

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                            clock:(id<RMQClock>)clock {
    self = [super init];
    if (self) {
        self.clock = clock;
        self.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        self.transport = transport;
        [self signalActivity];
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void (^)())startWithInterval:(NSNumber *)intervalSeconds {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dispatchQueue);
    
    void (^eventHandler)() = ^{
        if ([self intervalPassed:intervalSeconds]) [self.transport write:self.heartbeatData];
    };
    double leewaySeconds = 1;
    dispatch_source_set_timer(self.timer,
                              DISPATCH_TIME_NOW,
                              intervalSeconds.doubleValue * NSEC_PER_SEC,
                              leewaySeconds * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, eventHandler);
    dispatch_resume(self.timer);

    return eventHandler;
}

- (void)stop {
    if (self.timer) dispatch_source_cancel(self.timer);
    self.timer = nil;
}

- (void)signalActivity {
    self.lastBeatAt = self.clock.read;
}

# pragma mark - Private

- (BOOL)intervalPassed:(NSNumber *)intervalSeconds {
    return [self.clock.read timeIntervalSinceDate:self.lastBeatAt] > intervalSeconds.doubleValue;
}

- (NSData *)heartbeatData {
    return [RMQHeartbeat new].amqEncoded;
}

@end
