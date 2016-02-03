#import <Foundation/Foundation.h>
@import Mantle;
#import "AMQProtocol.h"

@protocol AMQEncoding <NSObject>
- (nonnull NSData *)amqEncoded;
@end

@protocol AMQBoolean <NSObject>
- (BOOL)boolValue;
@end

@interface AMQTrue : NSObject<AMQBoolean>
@end

@interface AMQFalse : NSObject<AMQBoolean>
@end

@interface AMQShortString : NSObject
@property (nonnull, nonatomic, copy, readonly) NSString *stringValue;
- (nonnull instancetype)initWithString:(nonnull NSString *)string;
@end

@interface AMQLongUInt : NSObject<AMQEncoding>
- (nonnull instancetype)init:(NSUInteger)val;
@end

@interface AMQCredentials : MTLModel<AMQEncoding>

@property (nonnull, nonatomic, readonly) NSString *username;
@property (nonnull, nonatomic, readonly) NSString *password;

- (nonnull instancetype)initWithUsername:(nonnull NSString *)username
                                password:(nonnull NSString *)password;

@end

@interface AMQProtocolBasicConsumeOk : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;
@property (nonnull, copy, nonatomic, readonly) NSString *consumerTag;
@end

@protocol AMQProtocolFrame <NSObject>
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

- (nonnull instancetype)initWithClientProperties:(nonnull NSDictionary<NSString *, id> *)clientProperties
                                       mechanism:(nonnull NSString *)mechanism
                                        response:(nonnull AMQCredentials *)response
                                          locale:(nonnull NSString *)locale;

@end