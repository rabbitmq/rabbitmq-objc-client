#import "RMQMultipleChannelAllocator.h"
#import "RMQDispatchQueueChannel.h"
#import "RMQUnallocatedChannel.h"
#import "AMQConstants.h"

@interface RMQMultipleChannelAllocator ()
@property (atomic, readwrite) UInt16 channelNumber;
@property (atomic, readwrite) NSMutableSet *allocatedNumbers;
@property (nonatomic, readwrite) id<RMQSender> sender;
@end

@implementation RMQMultipleChannelAllocator

- (instancetype)initWithSender:(id<RMQSender>)sender
{
    self = [super init];
    if (self) {
        self.sender = sender;
        self.channelNumber = 0;
        self.allocatedNumbers = [NSMutableSet new];
    }
    return self;
}

- (id<RMQChannel>)allocate {
    id<RMQChannel> ch;
    @synchronized(self) {
        ch = [self unsafeAllocateWithSender:self.sender];
    }
    return ch;
}

- (void)releaseChannelNumber:(NSNumber *)channelNumber {
    [self.allocatedNumbers removeObject:channelNumber];
}

- (void)handleFrameset:(AMQFrameset *)frameset {

}

- (id<RMQChannel>)unsafeAllocateWithSender:(id<RMQSender>)sender {
    if (self.allocatedNumbers.count == AMQChannelLimit) {
        return [RMQUnallocatedChannel new];
    } else if (self.channelNumber == AMQChannelLimit) {
        for (UInt16 i = 1; i < AMQChannelLimit; i++) {
            if (![self.allocatedNumbers containsObject:@(i)]) {
                [self.allocatedNumbers addObject:@(i)];
                RMQDispatchQueueChannel *ch = [[RMQDispatchQueueChannel alloc] init:@(i)
                                                                             sender:sender];
                return ch;
            }
        }
        return [RMQUnallocatedChannel new];
    } else {
        [self.allocatedNumbers addObject:@(self.channelNumber)];
        RMQDispatchQueueChannel *ch = [[RMQDispatchQueueChannel alloc] init:@(self.channelNumber)
                                                                     sender:sender];
        self.channelNumber++;
        return ch;
    }
}

@end
