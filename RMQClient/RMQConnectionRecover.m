#import "RMQConnectionRecover.h"

@interface RMQConnectionRecover ()
@property (nonatomic, readwrite) NSNumber *interval;
@property (nonatomic, readwrite) id<RMQStarter> connection;
@property (nonatomic, readwrite) id<RMQChannelAllocator> allocator;
@property (nonatomic, readwrite) id<RMQHeartbeatSender> heartbeatSender;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@end

@implementation RMQConnectionRecover

- (instancetype)initWithInterval:(NSNumber *)interval
                      connection:(id<RMQStarter>)connection
                channelAllocator:(id<RMQChannelAllocator>)allocator
                 heartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender
                    commandQueue:(id<RMQLocalSerialQueue>)commandQueue {
    self = [super init];
    if (self) {
        self.interval = interval;
        self.connection = connection;
        self.allocator = allocator;
        self.heartbeatSender = heartbeatSender;
        self.commandQueue = commandQueue;
    }
    return self;
}

- (void)recover {
    [self.commandQueue enqueue:^{
        [self.heartbeatSender stop];
    }];
    [self.commandQueue delayedBy:self.interval enqueue:^{
        [self.connection start];
        [self.commandQueue enqueue:^{
            for (id<RMQChannel> ch in self.allocator.allocatedUserChannels) {
                [ch recover];
            }
        }];
    }];
}

@end
