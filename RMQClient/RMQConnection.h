#import <Foundation/Foundation.h>
#import "AMQValues.h"
#import "RMQChannel.h"
#import "RMQFrameHandler.h"
#import "RMQSender.h"
#import "RMQTransport.h"

@interface RMQConnection : NSObject<RMQFrameHandler, RMQSender>

@property (nonnull, copy, nonatomic, readonly) NSString *vhost;

- (nonnull instancetype)initWithTransport:(nonnull id<RMQTransport>)transport
                                     user:(nonnull NSString *)user
                                 password:(nonnull NSString *)password
                                    vhost:(nonnull NSString *)vhost
                               channelMax:(nonnull NSNumber *)channelMax
                                 frameMax:(nonnull NSNumber *)frameMax
                                heartbeat:(nonnull NSNumber *)heartbeat
                              syncTimeout:(nonnull NSNumber *)syncTimeout;

- (nonnull instancetype)initWithUri:(nonnull NSString *)uri
                         channelMax:(nonnull NSNumber *)channelMax
                           frameMax:(nonnull NSNumber *)frameMax
                          heartbeat:(nonnull NSNumber *)heartbeat
                        syncTimeout:(nonnull NSNumber *)syncTimeout;

- (BOOL)startWithError:(NSError * _Nullable * _Nullable)error;
- (void)close;
- (nullable id<RMQChannel>)createChannelWithError:(NSError * _Nullable * _Nullable)error;

@end
