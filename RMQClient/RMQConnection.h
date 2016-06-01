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
#import "RMQTLSOptions.h"
#import "RMQStarter.h"

extern NSInteger const RMQChannelLimit;

@interface RMQConnection : NSObject<RMQFrameHandler, RMQSender, RMQStarter, RMQTransportDelegate>

@property (nonnull, copy, nonatomic, readonly) NSString *vhost;

# pragma mark - Designated initializer (implementation only)
- (nonnull instancetype)initWithTransport:(nonnull id<RMQTransport>)transport
                                   config:(nonnull RMQConnectionConfig *)config
                         handshakeTimeout:(nonnull NSNumber *)handshakeTimeout
                         channelAllocator:(nonnull id<RMQChannelAllocator>)channelAllocator
                             frameHandler:(nonnull id<RMQFrameHandler>)frameHandler
                                 delegate:(nullable id<RMQConnectionDelegate>)delegate
                             commandQueue:(nonnull id<RMQLocalSerialQueue>)commandQueue
                            waiterFactory:(nonnull id<RMQWaiterFactory>)waiterFactory
                          heartbeatSender:(nonnull id<RMQHeartbeatSender>)heartbeatSender;

# pragma mark - User-facing initializers
- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue
                       recoverAfter:(nonnull NSNumber *)recoveryInterval
                   recoveryAttempts:(nonnull NSNumber *)recoveryAttempts
         recoverFromConnectionClose:(BOOL)shouldRecoverFromConnectionClose;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                       recoverAfter:(nonnull NSNumber *)recoveryInterval;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout
                           delegate:(nullable id<RMQConnectionDelegate>)delegate
                      delegateQueue:(nonnull dispatch_queue_t)delegateQueue;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         tlsOptions:(nonnull RMQTLSOptions *)tlsOptions
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         verifyPeer:(BOOL)verifyPeer
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                           delegate:(nullable id<RMQConnectionDelegate>)delegate;

- (nonnull instancetype)initWithDelegate:(nullable id<RMQConnectionDelegate>)delegate;

# pragma mark - Other methods
- (void)close;
- (void)blockingClose;
- (nonnull id<RMQChannel>)createChannel;

@end
