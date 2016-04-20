#import "AMQConstants.h"
#import "RMQAllocatedChannel.h"
#import "RMQFramesetSemaphoreWaiter.h"
#import "RMQMultipleChannelAllocator.h"
#import "RMQSynchronizedMutableDictionary.h"
#import "RMQUnallocatedChannel.h"

@interface RMQMultipleChannelAllocator ()
@property (atomic, readwrite) UInt16 channelNumber;
@property (nonatomic, readwrite) RMQSynchronizedMutableDictionary *channels;
@end

@implementation RMQMultipleChannelAllocator
@synthesize sender;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channels = [RMQSynchronizedMutableDictionary new];
        self.channelNumber = 0;
        self.sender = nil;
    }
    return self;
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

# pragma mark - RMQFrameHandler

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
                                                         sender:self.sender
                                                         waiter:[[RMQFramesetSemaphoreWaiter alloc] initWithSyncTimeout:@2]
                                                          queue:[self suspendedDispatchQueue:self.channelNumber]];
    self.channels[@(self.channelNumber)] = ch;
    self.channelNumber++;
    return ch;
}

- (const char *)queueName:(UInt16)channelNumber {
    return [[NSString stringWithFormat:@"com.rabbitmq.ChannelQueue%d", channelNumber]
            cStringUsingEncoding:NSASCIIStringEncoding];
}

- (id<RMQChannel>)previouslyReleasedChannel {
    for (UInt16 i = 1; i < AMQChannelLimit; i++) {
        if (!self.channels[@(i)]) {
            RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(i)
                                                                 sender:self.sender
                                                                 waiter:[[RMQFramesetSemaphoreWaiter alloc] initWithSyncTimeout:@2]
                                                                  queue:[self suspendedDispatchQueue:i]];
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

- (dispatch_queue_t)suspendedDispatchQueue:(UInt16)channelNumber {
    dispatch_queue_t serialQueue = dispatch_queue_create([self queueName:channelNumber], NULL);
    dispatch_suspend(serialQueue);
    return serialQueue;
}

@end
