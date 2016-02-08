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

@interface AMQProtocolHeader : NSObject<AMQOutgoing>
@end

@interface AMQProtocolConnectionStart : MTLModel<NSCoding,AMQIncoming>
@property (nonnull, copy, nonatomic, readonly) AMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readonly) AMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readonly) AMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *locales;
@end

@interface AMQProtocolConnectionStartOk : MTLModel<NSCoding,AMQOutgoing>
- (nonnull instancetype)initWithClientProperties:(nonnull AMQTable *)clientProperties
                                       mechanism:(nonnull AMQShortstr *)mechanism
                                        response:(nonnull AMQCredentials *)response
                                          locale:(nonnull AMQShortstr *)locale;
@end

@interface AMQProtocolConnectionTune : MTLModel<NSCoding,AMQIncoming>
@end

@interface AMQProtocolConnectionTuneOk : MTLModel<NSCoding,AMQOutgoing>
- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat;
@end

@interface AMQProtocolConnectionOpen : MTLModel<NSCoding,AMQOutgoing>
- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortstr *)vhost
                               capabilities:(nonnull AMQShortstr *)capabilities
                                     insist:(nonnull AMQBoolean *)insist;
@end

@interface AMQProtocolConnectionOpenOk : MTLModel<NSCoding,AMQIncoming>
@end

@interface AMQProtocolChannelOpen : MTLModel<NSCoding,AMQOutgoing>
@end

@interface AMQProtocolChannelOpenOk : MTLModel<NSCoding,AMQIncoming>
@end