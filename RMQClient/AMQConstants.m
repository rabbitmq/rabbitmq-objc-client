#import "AMQConstants.h"
NSInteger const AMQEmptyFrameSize = 8;
NSInteger const AMQChannelLimit = 65535;
NSString * const RMQErrorDomain = @"com.rabbitmq.rabbitmq-objc-client";

// These aren't in an enum as I haven't figured out how to use an error enum from Swift.
NSInteger const RMQConnectionErrorHandshakeTimedOut = 1;
NSInteger const RMQChannelErrorUnallocated = 2;
NSInteger const RMQChannelErrorWaitTimeout = 3;
NSInteger const RMQChannelErrorIncorrectSyncMethod = 4;