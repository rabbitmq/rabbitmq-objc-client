#import "RMQChannel1Allocator.h"
#import "RMQDispatchQueueChannel.h"

@interface RMQChannel1Allocator ()
@property (nonatomic, readwrite) RMQDispatchQueueChannel *channel;
@end

@implementation RMQChannel1Allocator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channel = nil;
    }
    return self;
}

- (id<RMQChannel>)allocateWithSender:(id<RMQSender>)sender {
    self.channel = [[RMQDispatchQueueChannel alloc] init:@1 sender:sender];
    return self.channel;
}

- (void)handleFrameset:(AMQFrameset *)frameset {
    [self.channel handleFrameset:frameset];
}

@end
