#import <Foundation/Foundation.h>
#import "RMQConnectionRecovery.h"
#import "RMQChannelAllocator.h"
#import "RMQHeartbeatSender.h"
#import "RMQLocalSerialQueue.h"
#import "RMQConnectionDelegate.h"

@interface RMQConnectionRecover : NSObject <RMQConnectionRecovery>

- (instancetype)initWithInterval:(NSNumber *)interval
                 heartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender
                    commandQueue:(id<RMQLocalSerialQueue>)commandQueue
                        delegate:(id<RMQConnectionDelegate>)delegate;

@end
