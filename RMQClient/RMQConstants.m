#import "RMQConstants.h"
NSString * const RMQErrorDomain = @"com.rabbitmq.rabbitmq-objc-client";
NSString * const RMQClientVersion = @"0.0.1";

// These aren't in an enum as I haven't figured out how to use an error enum from Swift.
NSInteger const RMQChannelErrorUnallocated = 4;
NSInteger const RMQChannelErrorWaitTimeout = 5;
NSInteger const RMQChannelErrorIncorrectSyncMethod = 6;
NSInteger const RMQChannelErrorQueueNameCollision = 7;