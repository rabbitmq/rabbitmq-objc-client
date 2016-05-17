#import <Foundation/Foundation.h>
#import "RMQConnectionRecovery.h"

@class RMQCredentials;

@interface RMQConnectionConfig : NSObject
@property (nonnull, nonatomic, readonly) NSNumber *channelMax;
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
@property (nonnull, nonatomic, readonly) NSNumber *heartbeat;
@property (nonnull, nonatomic, readonly) NSString *vhost;
@property (nonnull, nonatomic, readonly) RMQCredentials *credentials;
@property (nonnull, nonatomic, readonly) NSString *authMechanism;
@property (nonnull, nonatomic, readonly) id<RMQConnectionRecovery> recovery;
- (nonnull instancetype)initWithCredentials:(nonnull RMQCredentials *)credentials
                                 channelMax:(nonnull NSNumber *)channelMax
                                   frameMax:(nonnull NSNumber *)frameMax
                                  heartbeat:(nonnull NSNumber *)heartbeat
                                      vhost:(nonnull NSString *)vhost
                              authMechanism:(nonnull NSString *)authMechanism
                                   recovery:(nonnull id<RMQConnectionRecovery>)recovery;
@end
