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

@interface AMQShortUInt : MTLModel<AMQEncoding,AMQFieldValue>
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQLongUInt : MTLModel<AMQEncoding,AMQFieldValue>
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQShortString : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface AMQLongString : MTLModel<AMQEncoding,AMQFieldValue>
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)init:(nonnull NSString *)string;
@end

@interface AMQFieldTable : MTLModel<AMQEncoding,AMQFieldValue>
- (nonnull instancetype)init:(nonnull NSDictionary *)dictionary;
@end

@interface AMQFieldValuePair : MTLModel<AMQEncoding>
- (nonnull instancetype)initWithFieldName:(nonnull NSString *)fieldName
                               fieldValue:(nonnull id <AMQEncoding,AMQFieldValue>)fieldValue;
@end

@interface AMQMethodPayload : NSObject<AMQEncoding>
- (nonnull instancetype)initWithClassID:(nonnull AMQShortUInt *)classID
                               methodID:(nonnull AMQShortUInt *)methodID
                                   data:(nonnull NSData *)data;
@end

@interface AMQProtocolHeader : NSObject<AMQOutgoing>
@end

@interface AMQProtocolConnectionStart : MTLModel<NSCoding,AMQIncoming>
@property (nonnull, copy, nonatomic, readonly) AMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readonly) AMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readonly) AMQFieldTable *serverProperties;
@property (nonnull, copy, nonatomic, readonly) AMQLongString *mechanisms;
@property (nonnull, copy, nonatomic, readonly) AMQLongString *locales;
@end

@interface AMQProtocolConnectionStartOk : MTLModel<NSCoding,AMQOutgoing>
- (nonnull instancetype)initWithClientProperties:(nonnull AMQFieldTable *)clientProperties
                                       mechanism:(nonnull AMQShortString *)mechanism
                                        response:(nonnull AMQCredentials *)response
                                          locale:(nonnull AMQShortString *)locale;
@end

@interface AMQProtocolConnectionTune : MTLModel<NSCoding,AMQIncoming>
@end

@interface AMQProtocolConnectionTuneOk : MTLModel<NSCoding,AMQOutgoing>
- (nonnull instancetype)initWithChannelMax:(nonnull AMQShortUInt *)channelMax
                                  frameMax:(nonnull AMQLongUInt *)frameMax
                                 heartbeat:(nonnull AMQShortUInt *)heartbeat;
@end

@interface AMQProtocolConnectionOpen : MTLModel<NSCoding,AMQOutgoing>
- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortString *)vhost
                               capabilities:(nonnull AMQShortString *)capabilities
                                     insist:(nonnull AMQBoolean *)insist;
@end

@interface AMQProtocolConnectionOpenOk : MTLModel<NSCoding,AMQIncoming>
@end

@interface AMQProtocolChannelOpen : MTLModel<NSCoding,AMQOutgoing>
@end

@interface AMQProtocolChannelOpenOk : MTLModel<NSCoding,AMQIncoming>
@end