#import "RMQConnectionConfig.h"

@interface RMQConnectionConfig ()
@property (nonnull, nonatomic, readwrite) NSNumber *channelMax;
@property (nonnull, nonatomic, readwrite) NSNumber *frameMax;
@property (nonnull, nonatomic, readwrite) NSNumber *heartbeat;
@property (nonnull, nonatomic, readwrite) NSString *vhost;
@property (nonnull, nonatomic, readwrite) RMQCredentials *credentials;
@property (nonnull, nonatomic, readwrite) NSString *authMechanism;
@end

@implementation RMQConnectionConfig
- (instancetype)initWithCredentials:(RMQCredentials *)credentials
                         channelMax:(NSNumber *)channelMax
                           frameMax:(NSNumber *)frameMax
                          heartbeat:(NSNumber *)heartbeat
                              vhost:(nonnull NSString *)vhost
                      authMechanism:(nonnull NSString *)authMechanism {
    self = [super init];
    if (self) {
        self.credentials = credentials;
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.vhost = vhost;
        self.authMechanism = authMechanism;
    }
    return self;
}
@end
