#import "RMQConstants.h"
#import "RMQAllocatedChannel.h"
#import "RMQFramesetSemaphoreWaiter.h"
#import "RMQMultipleChannelAllocator.h"
#import "RMQUnallocatedChannel.h"
#import "RMQGCDSerialQueue.h"
#import "RMQProcessInfoNameGenerator.h"

@interface RMQMultipleChannelAllocator ()
@property (atomic, readwrite) UInt16 channelNumber;
@property (nonatomic, readwrite) NSMutableDictionary *channels;
@property (nonatomic, readwrite) NSNumber *syncTimeout;
@property (nonatomic, readwrite) RMQProcessInfoNameGenerator *nameGenerator;
@end

@implementation RMQMultipleChannelAllocator
@synthesize sender;

- (instancetype)initWithChannelSyncTimeout:(NSNumber *)syncTimeout {
    self = [super init];
    if (self) {
        self.channels = [NSMutableDictionary new];
        self.channelNumber = 0;
        self.sender = nil;
        self.syncTimeout = syncTimeout;
        self.nameGenerator = [RMQProcessInfoNameGenerator new];
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

# pragma mark - RMQFrameHandler

- (void)handleFrameset:(RMQFrameset *)frameset {
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
    RMQFramesetSemaphoreWaiter *waiter = [[RMQFramesetSemaphoreWaiter alloc] initWithSyncTimeout:self.syncTimeout];
    RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(self.channelNumber)
                                                         sender:self.sender
                                                         waiter:waiter
                                                          queue:[self suspendedDispatchQueue:self.channelNumber]
                                                  nameGenerator:self.nameGenerator];
    self.channels[@(self.channelNumber)] = ch;
    self.channelNumber++;
    return ch;
}

- (const char *)queueName:(UInt16)channelNumber {
    return [[NSString stringWithFormat:@"com.rabbitmq.ChannelQueue%d", channelNumber]
            cStringUsingEncoding:NSASCIIStringEncoding];
}

- (id<RMQChannel>)previouslyReleasedChannel {
    for (UInt16 i = 1; i < RMQChannelLimit; i++) {
        if (!self.channels[@(i)]) {
            RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(i)
                                                                 sender:self.sender
                                                                 waiter:[[RMQFramesetSemaphoreWaiter alloc] initWithSyncTimeout:@2]
                                                                  queue:[self suspendedDispatchQueue:i]
                                                          nameGenerator:self.nameGenerator];
            self.channels[@(i)] = ch;
            return ch;
        }
    }
    return [RMQUnallocatedChannel new];
}

- (BOOL)atCapacity {
    return self.channels.count == RMQChannelLimit;
}

- (BOOL)atMaxIndex {
    return self.channelNumber == RMQChannelLimit;
}

- (RMQGCDSerialQueue *)suspendedDispatchQueue:(UInt16)channelNumber {
    RMQGCDSerialQueue *serialQueue = [RMQGCDSerialQueue new];
    [serialQueue suspend];
    return serialQueue;
}

@end
