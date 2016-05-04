#import <Foundation/Foundation.h>

extern NSString * const RMQErrorDomain;

typedef NS_ENUM(NSInteger, RMQError) {
    RMQErrorConnectionHandshakeTimedOut = 1,
    RMQErrorTLSCertificateAuthFailure,
    RMQErrorTLSCertificateDecodeError,

    RMQErrorChannelUnallocated,
    RMQErrorChannelWaitTimeout,
    RMQErrorChannelIncorrectSyncMethod,
    RMQErrorChannelQueueNameCollision,
};
