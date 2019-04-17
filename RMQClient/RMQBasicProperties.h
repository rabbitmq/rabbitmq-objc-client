// License goes here

// This file is generated. Do not edit.
#import "RMQTable.h"

@protocol RMQBasicValue <NSObject, RMQEncodable>
+ (NSUInteger)flagBit;
- (NSUInteger)flagBit;
@end

@interface RMQBasicProperties : NSObject
+ (NSArray *)properties;
+ (NSArray<RMQValue *> *)defaultProperties;
@end

@interface RMQBasicContentType : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicContentEncoding : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicHeaders : RMQTable <RMQBasicValue>
@end

@interface RMQBasicDeliveryMode : RMQOctet <RMQBasicValue>
@end

@interface RMQBasicPriority : RMQOctet <RMQBasicValue>
@end

@interface RMQBasicCorrelationId : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicReplyTo : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicExpiration : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicMessageId : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicTimestamp : RMQTimestamp <RMQBasicValue>
@end

@interface RMQBasicType : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicUserId : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicAppId : RMQShortstr <RMQBasicValue>
@end

@interface RMQBasicReserved : RMQShortstr <RMQBasicValue>
@end

