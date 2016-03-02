#import <Foundation/Foundation.h>
#import "RMQChannel.h"

@interface RMQDispatchQueueChannel : NSObject <RMQChannel>
- (nonnull instancetype)init:(nonnull NSNumber *)channelID
                      sender:(nonnull id <RMQSender>)sender;
@end
