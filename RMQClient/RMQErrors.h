#import <Foundation/Foundation.h>

extern NSString * const RMQErrorDomain;

typedef NS_ENUM(NSInteger, RMQError) {
    RMQErrorConnectionHandshakeTimedOut = 1,
    RMQErrorTLSCertificateAuthFailure,
    RMQErrorTLSCertificateDecodeError,
    RMQErrorSimulatedDisconnect,

    RMQErrorChannelClosed,
    RMQErrorChannelUnallocated,
    RMQErrorChannelWaitTimeout,
    RMQErrorChannelIncorrectSyncMethod,
    RMQErrorChannelQueueNameCollision,

    RMQErrorInvalidScheme,

    RMQErrorInvalidPath                 = 402,
    RMQErrorNotFound                    = 404,
};
