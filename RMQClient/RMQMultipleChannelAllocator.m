#import "RMQConnection.h"
#import "RMQAllocatedChannel.h"
#import "RMQFramesetValidator.h"
#import "RMQMultipleChannelAllocator.h"
#import "RMQUnallocatedChannel.h"
#import "RMQGCDSerialQueue.h"
#import "RMQProcessInfoNameGenerator.h"
#import "RMQFrame.h"
#import "RMQSuspendResumeDispatcher.h"

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

- (NSArray *)allocatedUserChannels {
    NSMutableArray *userChannels = [self.channels.allValues mutableCopy];
    [userChannels removeObjectAtIndex:0];
    return [userChannels sortedArrayUsingComparator:^NSComparisonResult(id<RMQChannel> ch1, id<RMQChannel> ch2) {
        return ch1.channelNumber.integerValue > ch2.channelNumber.integerValue;
    }];
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
    RMQGCDSerialQueue *commandQueue = [self suspendedDispatchQueue:self.channelNumber];
    RMQSuspendResumeDispatcher *dispatcher = [[RMQSuspendResumeDispatcher alloc] initWithSender:self.sender
                                                                                   commandQueue:commandQueue];
    RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(self.channelNumber)
                                                contentBodySize:@(self.sender.frameMax.integerValue - RMQEmptyFrameSize)
                                                     dispatcher:dispatcher
                                                   commandQueue:commandQueue
                                                  nameGenerator:self.nameGenerator
                                                      allocator:self];
    self.channels[@(self.channelNumber)] = ch;
    self.channelNumber++;
    return ch;
}

- (id<RMQChannel>)previouslyReleasedChannel {
    for (UInt16 i = 1; i < RMQChannelLimit; i++) {
        if (!self.channels[@(i)]) {
            RMQGCDSerialQueue *commandQueue = [self suspendedDispatchQueue:i];
            RMQSuspendResumeDispatcher *dispatcher = [[RMQSuspendResumeDispatcher alloc] initWithSender:self.sender
                                                                                           commandQueue:commandQueue];
            RMQAllocatedChannel *ch = [[RMQAllocatedChannel alloc] init:@(i)
                                                        contentBodySize:@(self.sender.frameMax.integerValue - RMQEmptyFrameSize)
                                                             dispatcher:dispatcher
                                                           commandQueue:[self suspendedDispatchQueue:i]
                                                          nameGenerator:self.nameGenerator
                                                              allocator:self];
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
    RMQGCDSerialQueue *serialQueue = [[RMQGCDSerialQueue alloc] initWithName:[NSString stringWithFormat:@"channel %d", channelNumber]];
    [serialQueue suspend];
    return serialQueue;
}

@end
