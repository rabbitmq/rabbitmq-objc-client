#import <Foundation/Foundation.h>

extern NSString * const RMQErrorDomain;

typedef NS_ENUM(NSInteger, RMQError) {
    RMQErrorConnectionHandshakeTimedOut = 1,
    RMQErrorTLSCertificateAuthFailure,
    RMQErrorTLSCertificateDecodeError,

    RMQErrorChannelClosed,
    RMQErrorChannelUnallocated,
    RMQErrorChannelWaitTimeout,
    RMQErrorChannelIncorrectSyncMethod,
    RMQErrorChannelQueueNameCollision,

    RMQErrorInvalidPath,
    RMQErrorInvalidScheme,
};
