#import <Foundation/Foundation.h>
@import Mantle;
#import "AMQParser.h"
#import "RMQConnectionConfig.h"

@protocol AMQEncoding <NSObject>
- (nonnull NSData *)amqEncoded;
@end

@protocol AMQParseable <NSObject>
- (nonnull instancetype)initWithParser:(nonnull AMQParser *)parser;
@end

@protocol AMQFieldValue <NSObject,AMQEncoding,AMQParseable>
- (nonnull NSData *)amqFieldValueType;
@end

@interface AMQOctet : MTLModel<AMQEncoding,AMQParseable>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(char)octet;
@end

@interface AMQBoolean : MTLModel<AMQEncoding,AMQFieldValue,AMQParseable>
@property (nonatomic, readonly) BOOL boolValue;
- (nonnull instancetype)init:(BOOL)boolean;
@end

@interface AMQShort : MTLModel<AMQFieldValue>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQLong : MTLModel<AMQFieldValue>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQLonglong : MTLModel<AMQFieldValue>
@property (nonatomic, readonly) uint64_t integerValue;
- (nonnull instancetype)init:(uint64_t)val;
@end

@interface AMQShortstr : MTLModel<AMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface AMQLongstr : MTLModel<AMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface AMQTable : MTLModel<AMQFieldValue>
- (nonnull instancetype)init:(nonnull NSDictionary *)dictionary;
@end

@interface AMQTimestamp : MTLModel<AMQFieldValue>
- (nonnull instancetype)init:(nonnull NSDate *)date;
@end

@interface AMQFieldValuePair : MTLModel<AMQEncoding>
- (nonnull instancetype)initWithFieldName:(nonnull NSString *)fieldName
                               fieldValue:(nonnull id <AMQEncoding,AMQFieldValue>)fieldValue;
@end

@interface AMQCredentials : AMQLongstr
- (nonnull instancetype)initWithUsername:(nonnull NSString *)username
                                password:(nonnull NSString *)password;
@end

@protocol AMQIncomingCallbackContext <NSObject>
- (void)close:(void (^ _Nonnull)())onClose;
@end

@protocol AMQPayload <NSObject, AMQEncoding>
- (nonnull NSNumber *)frameTypeID;
@end

@protocol AMQMethod <NSObject, AMQPayload>
+ (nonnull NSArray *)frame;
- (nonnull NSNumber *)classID;
- (nonnull instancetype)initWithDecodedFrame:(nonnull NSArray *)frame;
- (BOOL)hasContent;
- (BOOL)shouldHaltOnReceipt;
@end

@protocol AMQOutgoingPrecursor <NSObject>
- (nonnull id<AMQMethod>)nextRequest;
@end

@protocol AMQIncomingSync <NSObject,AMQMethod>
- (nonnull id<AMQMethod>)replyWithContext:(nonnull RMQConnectionConfig *)context;
@end

@interface AMQContentHeader : MTLModel<AMQPayload>
@property (nonnull, nonatomic, copy, readonly) NSNumber *bodySize;
- (nonnull instancetype)initWithClassID:(nonnull NSNumber *)classID
                               bodySize:(nonnull NSNumber *)bodySize
                             properties:(nonnull NSArray *)properties;
- (nonnull instancetype)initWithParser:(nonnull AMQParser *)parser;
@end

@interface AMQContentHeaderNone : AMQContentHeader
@end

@interface AMQContentBody : MTLModel<AMQPayload>
@property (nonnull, nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSUInteger length;
- (nonnull instancetype)initWithData:(nonnull NSData *)data;
- (nonnull instancetype)initWithParser:(nonnull AMQParser *)parser
                           payloadSize:(UInt32)payloadSize;
@end