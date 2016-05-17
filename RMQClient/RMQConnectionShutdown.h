#import <Foundation/Foundation.h>
#import "RMQConnectionRecovery.h"
#import "RMQHeartbeatSender.h"

@interface RMQConnectionShutdown : NSObject <RMQConnectionRecovery>

- (instancetype)initWithHeartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender;

@end
