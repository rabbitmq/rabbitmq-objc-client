#import <Foundation/Foundation.h>
@import Mantle;

@protocol AMQEncoding <NSObject>
- (nonnull NSData *)amqEncoded;
@end

@protocol AMQFieldValue <NSObject>
- (nonnull NSData *)amqFieldValueType;
@end

@protocol AMQOutgoing <NSObject,AMQEncoding>
- (nonnull Class)expectedResponseClass;

@optional
- (nonnull id<AMQOutgoing>)nextRequest;
@end

@interface AMQCredentials : MTLModel<AMQEncoding>
@property (nonnull, nonatomic, readonly) NSString *username;
@property (nonnull, nonatomic, readonly) NSString *password;
- (nonnull instancetype)initWithUsername:(nonnull NSString *)username
                                password:(nonnull NSString *)password;
@end

@protocol AMQReplyContext <NSObject>
- (nonnull AMQCredentials *)credentials;
@end

@protocol AMQIncoming <NSObject>
- (nonnull id<AMQOutgoing>)replyWithContext:(nonnull id<AMQReplyContext>)context;
@end

@interface AMQOctet : MTLModel<AMQEncoding>
- (nonnull instancetype)init:(char)octet;
@end

@interface AMQBoolean : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonatomic, readonly) BOOL boolValue;
- (nonnull instancetype)init:(BOOL)boolean;
@end

@interface AMQShort : MTLModel<AMQEncoding,AMQFieldValue>
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQLong : MTLModel<AMQEncoding,AMQFieldValue>
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

@interface AMQFieldValuePair : MTLModel<AMQEncoding>
- (nonnull instancetype)initWithFieldName:(nonnull NSString *)fieldName
                               fieldValue:(nonnull id <AMQEncoding,AMQFieldValue>)fieldValue;
@end

@interface AMQMethodPayload : NSObject<AMQEncoding>
- (nonnull instancetype)initWithClassID:(nonnull AMQShort *)classID
                               methodID:(nonnull AMQShort *)methodID
                                   data:(nonnull NSData *)data;
@end
