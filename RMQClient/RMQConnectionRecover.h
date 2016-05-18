#import <Foundation/Foundation.h>
#import "RMQConnectionRecovery.h"
#import "RMQChannelAllocator.h"
#import "RMQHeartbeatSender.h"
#import "RMQLocalSerialQueue.h"

@interface RMQConnectionRecover : NSObject <RMQConnectionRecovery>

- (instancetype)initWithInterval:(NSNumber *)interval
                      connection:(id<RMQStarter>)connection
                channelAllocator:(id<RMQChannelAllocator>)allocator
                 heartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender
                    commandQueue:(id<RMQLocalSerialQueue>)commandQueue;

@end
