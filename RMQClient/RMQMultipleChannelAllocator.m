#import "RMQMultipleChannelAllocator.h"
#import "RMQDispatchQueueChannel.h"
#import "AMQConstants.h"

@interface RMQMultipleChannelAllocator ()
@property (atomic, readwrite) UInt16 channelNumber;
@property (atomic, readwrite) NSMutableSet *allocatedNumbers;
@end

@implementation RMQMultipleChannelAllocator

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.channelNumber = 0;
        self.allocatedNumbers = [NSMutableSet new];
    }
    return self;
}

- (id<RMQChannel>)allocateWithSender:(id<RMQSender>)sender {
    id<RMQChannel> ch;
    @synchronized(self) {
        ch = [self unsafeAllocateWithSender:sender];
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
        return [RMQUnallocatedDispatchQueueChannel new];
    } else if (self.channelNumber == AMQChannelLimit) {
        for (UInt16 i = 1; i < AMQChannelLimit; i++) {
            if (![self.allocatedNumbers containsObject:@(i)]) {
                [self.allocatedNumbers addObject:@(i)];
                RMQDispatchQueueChannel *ch = [[RMQDispatchQueueChannel alloc] init:@(i)
                                                                             sender:sender];
                return ch;
            }
        }
        return [RMQUnallocatedDispatchQueueChannel new];
    } else {
        [self.allocatedNumbers addObject:@(self.channelNumber)];
        RMQDispatchQueueChannel *ch = [[RMQDispatchQueueChannel alloc] init:@(self.channelNumber)
                                                                     sender:sender];
        self.channelNumber++;
        return ch;
    }
}

@end
