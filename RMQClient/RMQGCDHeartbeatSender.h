#import <Foundation/Foundation.h>
#import "RMQHeartbeatSender.h"
#import "RMQTransport.h"
#import "RMQLocalSerialQueue.h"
#import "RMQWaiterFactory.h"
#import "RMQClock.h"

@interface RMQGCDHeartbeatSender : NSObject <RMQHeartbeatSender>

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                            clock:(id<RMQClock>)clock;

@end
