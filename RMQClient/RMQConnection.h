#import <Foundation/Foundation.h>
#import "AMQValues.h"
#import "RMQChannel.h"
#import "RMQFrameHandler.h"
#import "RMQSender.h"
#import "RMQTransport.h"

@interface RMQConnection : NSObject<RMQFrameHandler, RMQSender>

@property (copy, nonatomic, readonly) NSString *vhost;

- (instancetype)initWithTransport:(id<RMQTransport>)transport
                             user:(NSString *)user
                         password:(NSString *)password
                            vhost:(NSString *)vhost
                       channelMax:(NSNumber *)channelMax
                         frameMax:(NSNumber *)frameMax
                        heartbeat:(NSNumber *)heartbeat
                      syncTimeout:(NSNumber *)syncTimeout;

- (instancetype)initWithUri:(NSString *)uri
                 channelMax:(NSNumber *)channelMax
                   frameMax:(NSNumber *)frameMax
                  heartbeat:(NSNumber *)heartbeat
                syncTimeout:(NSNumber *)syncTimeout;

- (RMQConnection *)start;
- (void)close;
- (id<RMQChannel>)createChannel;

@end
