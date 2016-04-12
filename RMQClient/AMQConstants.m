#import "AMQConstants.h"
NSInteger const AMQEmptyFrameSize = 8;
NSInteger const AMQChannelLimit = 65535;
NSString * const RMQErrorDomain = @"com.rabbitmq.rabbitmq-objc-client";

// These aren't in an enum as I haven't figured out how to use an error enum from Swift.
NSInteger const RMQChannelErrorUnallocated = 1;
NSInteger const RMQChannelErrorWaitTimeout = 2;
NSInteger const RMQChannelErrorIncorrectSyncMethod = 3;