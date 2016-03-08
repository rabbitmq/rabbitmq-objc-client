#import "RMQMultipleChannelAllocator.h"
#import "RMQDispatchQueueChannel.h"
#import "RMQUnallocatedChannel.h"
#import "AMQConstants.h"

@interface RMQMultipleChannelAllocator ()
@property (atomic, readwrite) UInt16 channelNumber;
@property (nonatomic, readwrite) NSMutableDictionary *channels;
@property (nonatomic, readwrite) id<RMQSender> sender;
@end

@implementation RMQMultipleChannelAllocator

- (instancetype)initWithSender:(id<RMQSender>)sender
{
    self = [super init];
    if (self) {
        self.channels = [NSMutableDictionary new];
        self.sender = sender;
        self.channelNumber = 0;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id<RMQChannel>)allocate {
    id<RMQChannel> ch;
    @synchronized(self) {
        ch = self.unsafeAllocate;
    }
    return ch;
}

- (void)releaseChannelNumber:(NSNumber *)channelNumber {
    @synchronized(self) {
        [self unsafeReleaseChannelNumber:channelNumber];
    }
}

- (void)handleFrameset:(AMQFrameset *)frameset {
    RMQDispatchQueueChannel *ch = self.channels[frameset.channelNumber];
    [ch handleFrameset:frameset];
}

# pragma mark - Private

- (id<RMQChannel>)unsafeAllocate {
    if (self.atCapacity) {
        return [RMQUnallocatedChannel new];
    } else if (self.atMaxIndex) {
        return self.previouslyReleasedChannel;
    } else {
        return self.newAllocation;
    }
}

- (void)unsafeReleaseChannelNumber:(NSNumber *)channelNumber {
    [self.channels removeObjectForKey:channelNumber];
}

- (id<RMQChannel>)newAllocation {
    RMQDispatchQueueChannel *ch = [[RMQDispatchQueueChannel alloc] init:@(self.channelNumber)
                                                                 sender:self.sender];
    self.channels[@(self.channelNumber)] = ch;
    self.channelNumber++;
    return ch;
}

- (id<RMQChannel>)previouslyReleasedChannel {
    for (UInt16 i = 1; i < AMQChannelLimit; i++) {
        if (!self.channels[@(i)]) {
            RMQDispatchQueueChannel *ch = [[RMQDispatchQueueChannel alloc] init:@(i)
                                                                         sender:self.sender];
            self.channels[@(i)] = ch;
            return ch;
        }
    }
    return [RMQUnallocatedChannel new];
}

- (BOOL)atCapacity {
    return self.channels.count == AMQChannelLimit;
}

- (BOOL)atMaxIndex {
    return self.channelNumber == AMQChannelLimit;
}

@end
