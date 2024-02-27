// License goes here

// This file is generated. Do not edit.
#import "RMQBasicProperties.h"

@implementation RMQBasicProperties
+ (NSArray *)properties {
    return @[[RMQBasicContentType class],
             [RMQBasicContentEncoding class],
             [RMQBasicHeaders class],
             [RMQBasicDeliveryMode class],
             [RMQBasicPriority class],
             [RMQBasicCorrelationId class],
             [RMQBasicReplyTo class],
             [RMQBasicExpiration class],
             [RMQBasicMessageId class],
             [RMQBasicTimestamp class],
             [RMQBasicType class],
             [RMQBasicUserId class],
             [RMQBasicAppId class],
             [RMQBasicReserved class]];
}
+ (NSArray<RMQValue *> *)defaultProperties {
    return @[[[RMQBasicContentType alloc] init:@"application/octet-stream"],
             [[RMQBasicDeliveryMode alloc] init:1],
             [[RMQBasicPriority alloc] init:0]];
}
@end

@implementation RMQBasicContentType
+ (NSUInteger)flagBit { return 32768; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicContentEncoding
+ (NSUInteger)flagBit { return 16384; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicHeaders
+ (NSUInteger)flagBit { return 8192; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicDeliveryMode
+ (NSUInteger)flagBit { return 4096; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicPriority
+ (NSUInteger)flagBit { return 2048; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicCorrelationId
+ (NSUInteger)flagBit { return 1024; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicReplyTo
+ (NSUInteger)flagBit { return 512; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicExpiration
+ (NSUInteger)flagBit { return 256; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicMessageId
+ (NSUInteger)flagBit { return 128; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicTimestamp
+ (NSUInteger)flagBit { return 64; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicType
+ (NSUInteger)flagBit { return 32; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicUserId
+ (NSUInteger)flagBit { return 16; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicAppId
+ (NSUInteger)flagBit { return 8; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation RMQBasicReserved
+ (NSUInteger)flagBit { return 4; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

