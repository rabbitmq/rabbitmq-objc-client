#import <Foundation/Foundation.h>
#import "RMQValues.h"
#import "RMQChannel.h"
#import "RMQChannelAllocator.h"
#import "RMQConnectionDelegate.h"
#import "RMQFrameHandler.h"
#import "RMQHeartbeatSender.h"
#import "RMQSender.h"
#import "RMQTransport.h"
#import "RMQLocalSerialQueue.h"
#import "RMQWaiterFactory.h"

@interface RMQConnection : NSObject<RMQFrameHandler, RMQSender, RMQTransportDelegate>

@property (nonnull, copy, nonatomic, readonly) NSString *vhost;

# pragma mark - Designated initializer (implementation only)
- (nonnull instancetype)initWithTransport:(nonnull id<RMQTransport>)transport
                                     user:(nonnull NSString *)user
                                 password:(nonnull NSString *)password
                                    vhost:(nonnull NSString *)vhost
                               channelMax:(nonnull NSNumber *)channelMax
                                 frameMax:(nonnull NSNumber *)frameMax
                                heartbeat:(nonnull NSNumber *)heartbeat
                         handshakeTimeout:(nonnull NSNumber *)handshakeTimeout
                         channelAllocator:(nonnull id<RMQChannelAllocator>)channelAllocator
                             frameHandler:(nonnull id<RMQFrameHandler>)frameHandler
                                 delegate:(nullable id<RMQConnectionDelegate>)delegate
                             commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue
                            waiterFactory:(nonnull id<RMQWaiterFactory>)waiterFactory
                          heartbeatSender:(nonnull id<RMQHeartbeatSender>)heartbeatSender;

# pragma mark - User-facing initializers
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

- (nonnull instancetype)initWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;

# pragma mark - Other methods
- (void)start;
- (void)close;
- (void)blockingClose;
- (nonnull id<RMQChannel>)createChannel;

@end
