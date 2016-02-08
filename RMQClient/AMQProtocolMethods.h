#import <Foundation/Foundation.h>
@import Mantle;
#import "AMQProtocolValues.h"

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