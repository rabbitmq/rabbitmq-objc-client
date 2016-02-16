// This file is generated. Do not edit.
#import "AMQProtocolValues.h"

@protocol AMQBasicValue <NSObject, AMQEncoding>
- (NSUInteger)flagBit;
@end

@interface AMQBasicContentType : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicContentEncoding : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicHeaders : AMQTable <AMQBasicValue>
@end

@interface AMQBasicDeliveryMode : AMQOctet <AMQBasicValue>
@end

@interface AMQBasicPriority : AMQOctet <AMQBasicValue>
@end

@interface AMQBasicCorrelationId : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicReplyTo : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicExpiration : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicMessageId : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicTimestamp : AMQTimestamp <AMQBasicValue>
@end

@interface AMQBasicType : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicUserId : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicAppId : AMQShortstr <AMQBasicValue>
@end

@interface AMQBasicReserved : AMQShortstr <AMQBasicValue>
@end

