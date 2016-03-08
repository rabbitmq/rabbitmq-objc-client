#import "RMQConnectionConfig.h"

@interface RMQConnectionConfig ()
@property (nonnull, nonatomic, readwrite) NSNumber *channelMax;
@property (nonnull, nonatomic, readwrite) NSNumber *frameMax;
@property (nonnull, nonatomic, readwrite) NSNumber *heartbeat;
@property (nonnull, nonatomic, readwrite) AMQCredentials *credentials;
@end

@implementation RMQConnectionConfig
- (instancetype)initWithCredentials:(AMQCredentials *)credentials
                         channelMax:(NSNumber *)channelMax
                           frameMax:(NSNumber *)frameMax
                          heartbeat:(NSNumber *)heartbeat {
    self = [super init];
    if (self) {
        self.credentials = credentials;
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
    }
    return self;
}
@end
