#import "RMQConnectionShutdown.h"

@interface RMQConnectionShutdown ()
@property (nonatomic, readwrite) id<RMQHeartbeatSender> heartbeatSender;
@end

@implementation RMQConnectionShutdown

- (instancetype)initWithHeartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender {
    self = [super init];
    if (self) {
        self.heartbeatSender = heartbeatSender;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)recover {
    [self.heartbeatSender stop];
}

@end
