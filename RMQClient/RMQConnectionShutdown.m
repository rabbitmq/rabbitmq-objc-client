#import "RMQConnectionShutdown.h"

@interface RMQConnectionShutdown ()
@property (nonatomic, readwrite) id<RMQHeartbeatSender> heartbeatSender;
@property (nonatomic, readwrite) NSNumber *interval;
@end

@implementation RMQConnectionShutdown

- (instancetype)initWithHeartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender {
    self = [super init];
    if (self) {
        self.heartbeatSender = heartbeatSender;
        self.interval = @0;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-  (void)recover:(id<RMQStarter>)connection
channelAllocator:(id<RMQChannelAllocator>)allocator
           error:(NSError *)error {
    [self.heartbeatSender stop];
}

@end
