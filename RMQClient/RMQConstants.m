#import "RMQConstants.h"
NSInteger const RMQEmptyFrameSize = 8;
NSInteger const RMQChannelLimit = 65535;
NSString * const RMQErrorDomain = @"com.rabbitmq.rabbitmq-objc-client";
NSString * const RMQClientVersion = @"0.0.1";

// These aren't in an enum as I haven't figured out how to use an error enum from Swift.
NSInteger const RMQConnectionErrorHandshakeTimedOut = 1;
NSInteger const RMQChannelErrorUnallocated = 2;
NSInteger const RMQChannelErrorWaitTimeout = 3;
NSInteger const RMQChannelErrorIncorrectSyncMethod = 4;
NSInteger const RMQChannelErrorQueueNameCollision = 5;