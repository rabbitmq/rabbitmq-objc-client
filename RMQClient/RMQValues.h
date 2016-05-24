#import <Foundation/Foundation.h>
@import Mantle;
#import "RMQParser.h"
#import "RMQConnectionConfig.h"

@protocol RMQEncodable <NSObject>
- (nonnull NSData *)amqEncoded;
@end

@protocol RMQParseable <NSObject>
- (nonnull instancetype)initWithParser:(nonnull RMQParser *)parser;
@end

@protocol RMQFieldValue <NSObject,RMQEncodable,RMQParseable>
- (nonnull NSData *)amqFieldValueType;
@end

@interface RMQValue : MTLModel
@end

@interface RMQOctet : RMQValue<RMQEncodable,RMQParseable>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(char)octet;
@end

@interface RMQBoolean : RMQValue<RMQEncodable,RMQFieldValue,RMQParseable>
@property (nonatomic, readonly) BOOL boolValue;
- (nonnull instancetype)init:(BOOL)boolean;
@end

@interface RMQShort : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface RMQLong : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface RMQLonglong : RMQValue<RMQFieldValue>
@property (nonatomic, readonly) uint64_t integerValue;
- (nonnull instancetype)init:(uint64_t)val;
@end

@interface RMQShortstr : RMQValue<RMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface RMQLongstr : RMQValue<RMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface RMQTable : RMQValue<RMQFieldValue>
- (nonnull instancetype)init:(nonnull NSDictionary *)dictionary;
@end

@interface RMQTimestamp : RMQValue<RMQFieldValue>
- (nonnull instancetype)init:(nonnull NSDate *)date;
@end

@interface RMQFieldValuePair : RMQValue<RMQEncodable>
- (nonnull instancetype)initWithFieldName:(nonnull NSString *)fieldName
                               fieldValue:(nonnull id <RMQEncodable,RMQFieldValue>)fieldValue;
@end

@interface RMQCredentials : RMQLongstr
- (nonnull instancetype)initWithUsername:(nonnull NSString *)username
                                password:(nonnull NSString *)password;
@end

@protocol RMQPayload <NSObject, RMQEncodable>
- (nonnull NSNumber *)frameTypeID;
@end

@protocol RMQMethod <NSObject, RMQPayload>
+ (nonnull NSArray *)propertyClasses;
- (nonnull NSNumber *)classID;
- (nonnull NSNumber *)methodID;
- (nonnull Class)syncResponse;
- (nonnull instancetype)initWithDecodedFrame:(nonnull NSArray *)frame;
- (BOOL)hasContent;
@end

@interface RMQContentHeader : RMQValue<RMQPayload>
@property (nonnull, nonatomic, copy, readonly) NSNumber *bodySize;
- (nonnull instancetype)initWithClassID:(nonnull NSNumber *)classID
                               bodySize:(nonnull NSNumber *)bodySize
                             properties:(nonnull NSArray *)properties;
- (nonnull instancetype)initWithParser:(nonnull RMQParser *)parser;
@end

@interface RMQContentHeaderNone : RMQContentHeader
@end

@interface RMQContentBody : RMQValue<RMQPayload>
@property (nonnull, nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSUInteger length;
- (nonnull instancetype)initWithData:(nonnull NSData *)data;
- (nonnull instancetype)initWithParser:(nonnull RMQParser *)parser
                           payloadSize:(UInt32)payloadSize;
@end