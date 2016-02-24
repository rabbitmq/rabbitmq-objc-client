#import <Foundation/Foundation.h>
#import "RMQChannel.h"
#import "RMQTransport.h"
#import "RMQIDAllocator.h"
#import "AMQProtocolValues.h"
#import "RMQFrameHandler.h"
#import "RMQSender.h"

@interface RMQConnection : NSObject<AMQReplyContext, RMQFrameHandler, RMQSender>
@property (copy, nonatomic, readonly) NSString *vhost;

- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id <RMQTransport>)transport
                 idAllocator:(id <RMQIDAllocator>)idAllocator;
- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id <RMQTransport>)transport
                 idAllocator:(id <RMQIDAllocator>)idAllocator
                  channelMax:(NSNumber *)channelMax
                    frameMax:(NSNumber *)frameMax
                   heartbeat:(NSNumber *)heartbeat;
- (RMQConnection *)start;
- (void)close;
- (RMQChannel *)createChannel;
@end
