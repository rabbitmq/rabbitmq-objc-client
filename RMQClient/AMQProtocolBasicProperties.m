// This file is generated. Do not edit.
#import "AMQProtocolBasicProperties.h"

@implementation AMQBasicProperties
+ (NSArray *)properties {
    return @[[AMQBasicContentType class],
             [AMQBasicContentEncoding class],
             [AMQBasicHeaders class],
             [AMQBasicDeliveryMode class],
             [AMQBasicPriority class],
             [AMQBasicCorrelationId class],
             [AMQBasicReplyTo class],
             [AMQBasicExpiration class],
             [AMQBasicMessageId class],
             [AMQBasicTimestamp class],
             [AMQBasicType class],
             [AMQBasicUserId class],
             [AMQBasicAppId class],
             [AMQBasicReserved class]];
}
@end

@implementation AMQBasicContentType
+ (NSUInteger)flagBit { return 32768; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicContentEncoding
+ (NSUInteger)flagBit { return 16384; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicHeaders
+ (NSUInteger)flagBit { return 8192; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicDeliveryMode
+ (NSUInteger)flagBit { return 4096; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicPriority
+ (NSUInteger)flagBit { return 2048; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicCorrelationId
+ (NSUInteger)flagBit { return 1024; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicReplyTo
+ (NSUInteger)flagBit { return 512; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicExpiration
+ (NSUInteger)flagBit { return 256; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicMessageId
+ (NSUInteger)flagBit { return 128; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicTimestamp
+ (NSUInteger)flagBit { return 64; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicType
+ (NSUInteger)flagBit { return 32; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicUserId
+ (NSUInteger)flagBit { return 16; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicAppId
+ (NSUInteger)flagBit { return 8; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

@implementation AMQBasicReserved
+ (NSUInteger)flagBit { return 4; }
- (NSUInteger)flagBit { return [self class].flagBit; }
@end

