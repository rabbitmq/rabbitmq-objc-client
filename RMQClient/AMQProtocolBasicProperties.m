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
- (NSUInteger)flagBit { return 32768; }
@end

@implementation AMQBasicContentEncoding
- (NSUInteger)flagBit { return 16384; }
@end

@implementation AMQBasicHeaders
- (NSUInteger)flagBit { return 8192; }
@end

@implementation AMQBasicDeliveryMode
- (NSUInteger)flagBit { return 4096; }
@end

@implementation AMQBasicPriority
- (NSUInteger)flagBit { return 2048; }
@end

@implementation AMQBasicCorrelationId
- (NSUInteger)flagBit { return 1024; }
@end

@implementation AMQBasicReplyTo
- (NSUInteger)flagBit { return 512; }
@end

@implementation AMQBasicExpiration
- (NSUInteger)flagBit { return 256; }
@end

@implementation AMQBasicMessageId
- (NSUInteger)flagBit { return 128; }
@end

@implementation AMQBasicTimestamp
- (NSUInteger)flagBit { return 64; }
@end

@implementation AMQBasicType
- (NSUInteger)flagBit { return 32; }
@end

@implementation AMQBasicUserId
- (NSUInteger)flagBit { return 16; }
@end

@implementation AMQBasicAppId
- (NSUInteger)flagBit { return 8; }
@end

@implementation AMQBasicReserved
- (NSUInteger)flagBit { return 4; }
@end

