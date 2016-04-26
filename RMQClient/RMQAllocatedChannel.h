#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "RMQFramesetWaiter.h"
#import "RMQLocalSerialQueue.h"
#import "RMQNameGenerator.h"

@interface RMQAllocatedChannel : MTLModel <RMQChannel>
- (nonnull instancetype)init:(nonnull NSNumber *)channelNumber
                      sender:(nonnull id <RMQSender>)sender
                      waiter:(nonnull id<RMQFramesetWaiter>)waiter
                commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue
               nameGenerator:(nullable id<RMQNameGenerator>)nameGenerator;

- (nonnull instancetype)init:(nonnull NSNumber *)channelNumber
                      sender:(nonnull id <RMQSender>)sender
                      waiter:(nonnull id<RMQFramesetWaiter>)waiter
                commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue;
@end
