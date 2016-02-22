#import <Foundation/Foundation.h>
@import Mantle;

@protocol AMQEncoding <NSObject>
- (nonnull NSData *)amqEncoded;
@end

@protocol AMQFieldValue <NSObject>
- (nonnull NSData *)amqFieldValueType;
@end

@interface AMQOctet : MTLModel<AMQEncoding>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(char)octet;
@end

@interface AMQBoolean : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonatomic, readonly) BOOL boolValue;
- (nonnull instancetype)init:(BOOL)boolean;
@end

@interface AMQShort : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQLong : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonatomic, readonly) NSUInteger integerValue;
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQLonglong : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonatomic, readonly) uint64_t integerValue;
- (nonnull instancetype)init:(uint64_t)val;
@end

@interface AMQShortstr : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface AMQLongstr : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface AMQTable : MTLModel<AMQEncoding,AMQFieldValue>
- (nonnull instancetype)init:(nonnull NSDictionary *)dictionary;
@end

@interface AMQTimestamp : MTLModel<AMQEncoding,AMQFieldValue>
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

@protocol AMQReplyContext <NSObject>
- (nonnull AMQCredentials *)credentials;
@end

@protocol AMQIncomingCallbackContext <NSObject>
- (void)close:(void (^ _Nonnull)())onClose;
@end

@protocol AMQPayload <NSObject, AMQEncoding>
- (nonnull NSNumber *)frameTypeID;
@end

@protocol AMQMethod <NSObject, AMQPayload>
@property (nonatomic, readonly) BOOL hasContent;
+ (nonnull NSArray *)frame;
- (nonnull instancetype)initWithDecodedFrame:(nonnull NSArray *)frame;
@end

@protocol AMQAwaitServerMethod <NSObject>
@end

@protocol AMQOutgoingSync <NSObject, AMQAwaitServerMethod>
@end

@protocol AMQOutgoingPrecursor <NSObject>
- (nonnull id<AMQMethod>)nextRequest;
@end

@protocol AMQIncomingSync <NSObject,AMQMethod>
- (nonnull id<AMQMethod>)replyWithContext:(nonnull id<AMQReplyContext>)context;
@end

@protocol AMQIncomingCallback <NSObject>
- (void)didReceiveWithContext:(nonnull id<AMQIncomingCallbackContext>)context;
@end

@interface AMQContentHeader : NSObject<AMQPayload>
- (nonnull instancetype)initWithClassID:(nonnull NSNumber *)classID
                               bodySize:(nonnull NSNumber *)bodySize
                             properties:(nonnull NSArray *)properties;
@end

@interface AMQContentBody : NSObject<AMQPayload>
- (nonnull instancetype)initWithData:(nonnull NSData *)data;
@end

@interface AMQFrameset : MTLModel<AMQEncoding>
@property (nonnull, nonatomic, copy, readonly) id<AMQMethod>method;
@property (nonnull, nonatomic, copy, readonly) NSNumber *channelID;
@property (nonnull, nonatomic, readonly) NSArray *frames;
- (nonnull instancetype)initWithChannelID:(nonnull NSNumber *)channelID
                                   method:(nonnull id<AMQMethod>)method
                            contentHeader:(nonnull AMQContentHeader *)contentHeader
                            contentBodies:(nonnull NSArray *)contentBodies;
@end

@interface AMQFrame : MTLModel<AMQEncoding>
- (nonnull instancetype)initWithChannelID:(nonnull NSNumber *)channelID
                                  payload:(nonnull id<AMQEncoding>)payload;
@end