#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "RMQFramesetWaiter.h"

@interface RMQAllocatedChannel : MTLModel <RMQChannel>
- (nonnull instancetype)init:(nonnull NSNumber *)channelNumber
                      sender:(nonnull id <RMQSender>)sender
                      waiter:(nonnull id<RMQFramesetWaiter>)waiter
                       queue:(nonnull dispatch_queue_t)queue;
@end
