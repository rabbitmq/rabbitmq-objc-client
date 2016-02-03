#import <Foundation/Foundation.h>
@import Mantle;
#import "AMQProtocol.h"

@protocol AMQEncoding <NSObject>
- (nonnull NSData *)amqEncoded;
@end

@protocol AMQFieldValue <NSObject>
- (nonnull NSData *)amqFieldValueType;
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

@interface AMQCredentials : MTLModel<AMQEncoding>

@property (nonnull, nonatomic, readonly) NSString *username;
@property (nonnull, nonatomic, readonly) NSString *password;

- (nonnull instancetype)initWithUsername:(nonnull NSString *)username
                                password:(nonnull NSString *)password;

@end

@interface AMQProtocolHeader : NSObject<AMQEncoding>
@end

@interface AMQProtocolBasicConsumeOk : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;
@property (nonnull, copy, nonatomic, readonly) NSString *consumerTag;
@end

@interface AMQProtocolConnectionStart : MTLModel<NSCoding>

@property (nonnull, copy, nonatomic, readonly) NSNumber *versionMajor;
@property (nonnull, copy, nonatomic, readonly) NSNumber *versionMinor;
@property (nonnull, copy, nonatomic, readonly) NSDictionary<NSObject *, NSObject *> *serverProperties;
@property (nonnull, copy, nonatomic, readonly) NSString *mechanisms;
@property (nonnull, copy, nonatomic, readonly) NSString *locales;

- (nonnull instancetype)initWithVersionMajor:(nonnull NSNumber *)versionMajor
                                versionMinor:(nonnull NSNumber *)versionMinor
                            serverProperties:(nonnull NSDictionary<NSObject *, NSObject *> *)serverProperties
                                  mechanisms:(nonnull NSString *)mechanisms
                                     locales:(nonnull NSString *)locales;

@end

@interface AMQProtocolConnectionStartOk : MTLModel<NSCoding>

- (nonnull instancetype)initWithClientProperties:(nonnull AMQFieldTable *)clientProperties
                                       mechanism:(nonnull NSString *)mechanism
                                        response:(nonnull AMQCredentials *)response
                                          locale:(nonnull NSString *)locale;

@end