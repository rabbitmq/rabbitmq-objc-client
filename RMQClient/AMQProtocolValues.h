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

@interface AMQBit : AMQOctet
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
- (nonnull instancetype)init:(NSUInteger)val;
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

@protocol AMQMethod <NSObject>
@property (nonnull, nonatomic, readwrite) NSArray *frameArguments;
+ (nonnull NSNumber *)classID;
+ (nonnull NSNumber *)methodID;
+ (nonnull NSArray *)frames;
- (nonnull instancetype)initWithDecodedFrames:(nonnull NSArray *)frames;
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

@interface AMQFrameset : MTLModel
@property (nonnull, nonatomic, copy, readonly) id<AMQMethod>method;
@property (nonnull, nonatomic, copy, readonly) NSNumber *channelID;
@property (nonnull, nonatomic, readonly) NSArray *frames;
- (nonnull instancetype)initWithTypeID:(nonnull NSNumber *)typeID
                             channelID:(nonnull NSNumber *)channelID
                                method:(nonnull id<AMQMethod>)method;
@end

@interface AMQMethodFrame : MTLModel<AMQEncoding>
- (nonnull instancetype)initWithTypeID:(nonnull NSNumber *)typeID
                             channelID:(nonnull NSNumber *)channelID
                                method:(nonnull id<AMQMethod>)method;
@end

@interface AMQMethodPayload : NSObject<AMQEncoding>
- (nonnull instancetype)initWithClassID:(nonnull NSNumber *)classID
                               methodID:(nonnull NSNumber *)methodID
                              arguments:(nonnull NSArray *)arguments;
@end