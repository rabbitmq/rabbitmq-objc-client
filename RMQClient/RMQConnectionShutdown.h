#import <Foundation/Foundation.h>
#import "RMQConnectionRecovery.h"
#import "RMQChannelAllocator.h"
#import "RMQHeartbeatSender.h"

@interface RMQConnectionShutdown : NSObject <RMQConnectionRecovery>

- (instancetype)initWithConnection:(id<RMQStarter>)connection
                  channelAllocator:(id<RMQChannelAllocator>)allocator
                   heartbeatSender:(id<RMQHeartbeatSender>)heartbeatSender;

@end
