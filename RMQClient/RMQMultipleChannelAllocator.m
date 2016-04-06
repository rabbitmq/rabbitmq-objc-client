#import "AMQConstants.h"
#import "RMQMultipleChannelAllocator.h"
#import "RMQAllocatedChannel.h"
#import "RMQSynchronizedMutableDictionary.h"
#import "RMQUnallocatedChannel.h"

@interface RMQMultipleChannelAllocator ()
@property (atomic, readwrite) UInt16 channelNumber;
@property (nonatomic, readwrite) RMQSynchronizedMutableDictionary *channels;
@property (nonatomic, readwrite) id<RMQSender> sender;
@end

@implementation RMQMultipleChannelAllocator

- (instancetype)initWithSender:(id<RMQSender>)sender
{
    self = [super init];
    if (self) {
        self.channels = [RMQSynchronizedMutableDictionary new];
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
    RMQAllocatedChannel *ch = self.channels[frameset.channelNumber];
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
    RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(self.channelNumber)
                                                                 sender:self.sender];
    self.channels[@(self.channelNumber)] = ch;
    self.channelNumber++;
    return ch;
}

- (id<RMQChannel>)previouslyReleasedChannel {
    for (UInt16 i = 1; i < AMQChannelLimit; i++) {
        if (!self.channels[@(i)]) {
            RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(i)
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
