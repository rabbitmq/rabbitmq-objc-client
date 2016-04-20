#import <Foundation/Foundation.h>

@class RMQCredentials;

@interface RMQConnectionConfig : NSObject
@property (nonnull, nonatomic, readonly) NSNumber *channelMax;
@property (nonnull, nonatomic, readonly) NSNumber *frameMax;
@property (nonnull, nonatomic, readonly) NSNumber *heartbeat;
@property (nonnull, nonatomic, readonly) RMQCredentials *credentials;
- (nonnull instancetype)initWithCredentials:(nonnull RMQCredentials *)credentials
                                 channelMax:(nonnull NSNumber *)channelMax
                                   frameMax:(nonnull NSNumber *)frameMax
                                  heartbeat:(nonnull NSNumber *)heartbeat;
@end
