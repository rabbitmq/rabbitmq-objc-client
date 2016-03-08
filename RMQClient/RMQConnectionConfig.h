#import <Foundation/Foundation.h>

@class AMQCredentials;

@interface RMQConnectionConfig : NSObject
@property (nonnull, nonatomic, readonly) NSNumber *channelMax;
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
@property (nonnull, nonatomic, readonly) NSNumber *heartbeat;
@property (nonnull, nonatomic, readonly) AMQCredentials *credentials;
- (nonnull instancetype)initWithCredentials:(nonnull AMQCredentials *)credentials
                                 channelMax:(nonnull NSNumber *)channelMax
                                   frameMax:(nonnull NSNumber *)frameMax
                                  heartbeat:(nonnull NSNumber *)heartbeat;
@end
