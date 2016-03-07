#import <Foundation/Foundation.h>
#import "RMQChannel.h"

@interface RMQDispatchQueueChannel : MTLModel <RMQChannel>
- (nonnull instancetype)init:(nonnull NSNumber *)channelNumber
                      sender:(nonnull id <RMQSender>)sender;
@end
