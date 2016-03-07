#import "RMQChannel1Allocator.h"
#import "RMQDispatchQueueChannel.h"

@interface RMQChannel1Allocator ()
@property (nonatomic, readwrite) RMQDispatchQueueChannel *channel;
@property (nonatomic, readwrite) id<RMQSender> sender;
@end

@implementation RMQChannel1Allocator

- (instancetype)initWithSender:(id<RMQSender>)sender {
    self = [super init];
    if (self) {
        self.channel = nil;
        self.sender = sender;
    }
    return self;
}

- (id<RMQChannel>)allocate {
    self.channel = [[RMQDispatchQueueChannel alloc] init:@1 sender:self.sender];
    return self.channel;
}

- (void)releaseChannelNumber:(NSNumber *)channelNumber {

}

- (void)handleFrameset:(AMQFrameset *)frameset {
    [self.channel handleFrameset:frameset];
}

@end
