#import "RMQConnectionShutdown.h"

@interface RMQConnectionShutdown ()
@property (nonatomic, readwrite) id<RMQStarter> connection;
@property (nonatomic, readwrite) id<RMQChannelAllocator> allocator;
@property (nonatomic, readwrite) id<RMQHeartbeatSender> heartbeatSender;
@end

@implementation RMQConnectionShutdown

- (instancetype)initWithConnection:(id<RMQStarter>)connection
                  channelAllocator:(id<RMQChannelAllocator>)allocator
                   heartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender {
    self = [super init];
    if (self) {
        self.connection = connection;
        self.allocator = allocator;
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
