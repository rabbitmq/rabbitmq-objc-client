// This file is generated. Do not edit.
#import "AMQProtocolMethods.h"

@interface AMQProtocolConnectionStart ()
@property (copy, nonatomic, readwrite) AMQOctet *versionMajor;
@property (copy, nonatomic, readwrite) AMQOctet *versionMinor;
@property (copy, nonatomic, readwrite) AMQTable *serverProperties;
@property (copy, nonatomic, readwrite) AMQLongstr *mechanisms;
@property (copy, nonatomic, readwrite) AMQLongstr *locales;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionStart

+ (NSArray *)frames {
    return @[@[[AMQOctet class],
               [AMQOctet class],
               [AMQTable class],
               [AMQLongstr class],
               [AMQLongstr class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithVersionMajor:(nonnull AMQOctet *)versionMajor
                                versionMinor:(nonnull AMQOctet *)versionMinor
                            serverProperties:(nonnull AMQTable *)serverProperties
                                  mechanisms:(nonnull AMQLongstr *)mechanisms
                                     locales:(nonnull AMQLongstr *)locales {
    self = [super init];
    if (self) {
        self.versionMajor = versionMajor;
        self.versionMinor = versionMinor;
        self.serverProperties = serverProperties;
        self.mechanisms = mechanisms;
        self.locales = locales;
        self.payloadArguments = @[self.versionMajor,
                                  self.versionMinor,
                                  self.serverProperties,
                                  self.mechanisms,
                                  self.locales];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.versionMajor = frames[0][0];
        self.versionMinor = frames[0][1];
        self.serverProperties = frames[0][2];
        self.mechanisms = frames[0][3];
        self.locales = frames[0][4];
        self.payloadArguments = @[self.versionMajor,
                                  self.versionMinor,
                                  self.serverProperties,
                                  self.mechanisms,
                                  self.locales];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionStartOk ()
@property (copy, nonatomic, readwrite) AMQTable *clientProperties;
@property (copy, nonatomic, readwrite) AMQShortstr *mechanism;
@property (copy, nonatomic, readwrite) AMQLongstr *response;
@property (copy, nonatomic, readwrite) AMQShortstr *locale;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionStartOk

+ (NSArray *)frames {
    return @[@[[AMQTable class],
               [AMQShortstr class],
               [AMQLongstr class],
               [AMQShortstr class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithClientProperties:(nonnull AMQTable *)clientProperties
                                       mechanism:(nonnull AMQShortstr *)mechanism
                                        response:(nonnull AMQLongstr *)response
                                          locale:(nonnull AMQShortstr *)locale {
    self = [super init];
    if (self) {
        self.clientProperties = clientProperties;
        self.mechanism = mechanism;
        self.response = response;
        self.locale = locale;
        self.payloadArguments = @[self.clientProperties,
                                  self.mechanism,
                                  self.response,
                                  self.locale];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.clientProperties = frames[0][0];
        self.mechanism = frames[0][1];
        self.response = frames[0][2];
        self.locale = frames[0][3];
        self.payloadArguments = @[self.clientProperties,
                                  self.mechanism,
                                  self.response,
                                  self.locale];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionSecure ()
@property (copy, nonatomic, readwrite) AMQLongstr *challenge;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionSecure

+ (NSArray *)frames {
    return @[@[[AMQLongstr class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithChallenge:(nonnull AMQLongstr *)challenge {
    self = [super init];
    if (self) {
        self.challenge = challenge;
        self.payloadArguments = @[self.challenge];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.challenge = frames[0][0];
        self.payloadArguments = @[self.challenge];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionSecureOk ()
@property (copy, nonatomic, readwrite) AMQLongstr *response;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionSecureOk

+ (NSArray *)frames {
    return @[@[[AMQLongstr class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithResponse:(nonnull AMQLongstr *)response {
    self = [super init];
    if (self) {
        self.response = response;
        self.payloadArguments = @[self.response];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.response = frames[0][0];
        self.payloadArguments = @[self.response];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionTune ()
@property (copy, nonatomic, readwrite) AMQShort *channelMax;
@property (copy, nonatomic, readwrite) AMQLong *frameMax;
@property (copy, nonatomic, readwrite) AMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionTune

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQLong class],
               [AMQShort class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.channelMax = frames[0][0];
        self.frameMax = frames[0][1];
        self.heartbeat = frames[0][2];
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionTuneOk ()
@property (copy, nonatomic, readwrite) AMQShort *channelMax;
@property (copy, nonatomic, readwrite) AMQLong *frameMax;
@property (copy, nonatomic, readwrite) AMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionTuneOk

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQLong class],
               [AMQShort class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.channelMax = frames[0][0];
        self.frameMax = frames[0][1];
        self.heartbeat = frames[0][2];
        self.payloadArguments = @[self.channelMax,
                                  self.frameMax,
                                  self.heartbeat];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionOpen ()
@property (copy, nonatomic, readwrite) AMQShortstr *virtualHost;
@property (copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (copy, nonatomic, readwrite) AMQBit *reserved2;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionOpen

+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortstr *)virtualHost
                                  reserved1:(nonnull AMQShortstr *)reserved1
                                  reserved2:(nonnull AMQBit *)reserved2 {
    self = [super init];
    if (self) {
        self.virtualHost = virtualHost;
        self.reserved1 = reserved1;
        self.reserved2 = reserved2;
        self.payloadArguments = @[self.virtualHost,
                                  self.reserved1,
                                  self.reserved2];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.virtualHost = frames[0][0];
        self.reserved1 = frames[0][1];
        self.reserved2 = frames[0][2];
        self.payloadArguments = @[self.virtualHost,
                                  self.reserved1,
                                  self.reserved2];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionOpenOk ()
@property (copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionOpenOk

+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @41; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionClose ()
@property (copy, nonatomic, readwrite) AMQShort *replyCode;
@property (copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (copy, nonatomic, readwrite) AMQShort *classId;
@property (copy, nonatomic, readwrite) AMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionClose

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @50; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                  classId:(nonnull AMQShort *)classId
                                 methodId:(nonnull AMQShort *)methodId {
    self = [super init];
    if (self) {
        self.replyCode = replyCode;
        self.replyText = replyText;
        self.classId = classId;
        self.methodId = methodId;
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.replyCode = frames[0][0];
        self.replyText = frames[0][1];
        self.classId = frames[0][2];
        self.methodId = frames[0][3];
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionCloseOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionCloseOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @51; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionBlocked ()
@property (copy, nonatomic, readwrite) AMQShortstr *reason;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionBlocked

+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @60; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReason:(nonnull AMQShortstr *)reason {
    self = [super init];
    if (self) {
        self.reason = reason;
        self.payloadArguments = @[self.reason];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reason = frames[0][0];
        self.payloadArguments = @[self.reason];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConnectionUnblocked ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConnectionUnblocked

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @61; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolChannelOpen ()
@property (copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolChannelOpen

+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolChannelOpenOk ()
@property (copy, nonatomic, readwrite) AMQLongstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolChannelOpenOk

+ (NSArray *)frames {
    return @[@[[AMQLongstr class]]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQLongstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolChannelFlow ()
@property (copy, nonatomic, readwrite) AMQBit *active;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolChannelFlow

+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithActive:(nonnull AMQBit *)active {
    self = [super init];
    if (self) {
        self.active = active;
        self.payloadArguments = @[self.active];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.active = frames[0][0];
        self.payloadArguments = @[self.active];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolChannelFlowOk ()
@property (copy, nonatomic, readwrite) AMQBit *active;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolChannelFlowOk

+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithActive:(nonnull AMQBit *)active {
    self = [super init];
    if (self) {
        self.active = active;
        self.payloadArguments = @[self.active];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.active = frames[0][0];
        self.payloadArguments = @[self.active];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolChannelClose ()
@property (copy, nonatomic, readwrite) AMQShort *replyCode;
@property (copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (copy, nonatomic, readwrite) AMQShort *classId;
@property (copy, nonatomic, readwrite) AMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolChannelClose

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                  classId:(nonnull AMQShort *)classId
                                 methodId:(nonnull AMQShort *)methodId {
    self = [super init];
    if (self) {
        self.replyCode = replyCode;
        self.replyText = replyText;
        self.classId = classId;
        self.methodId = methodId;
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.replyCode = frames[0][0];
        self.replyText = frames[0][1];
        self.classId = frames[0][2];
        self.methodId = frames[0][3];
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.classId,
                                  self.methodId];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolChannelCloseOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolChannelCloseOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @41; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeDeclare ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQShortstr *type;
@property (copy, nonatomic, readwrite) AMQBit *passive;
@property (copy, nonatomic, readwrite) AMQBit *durable;
@property (copy, nonatomic, readwrite) AMQBit *autoDelete;
@property (copy, nonatomic, readwrite) AMQBit *internal;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeDeclare

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQTable class]]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                     type:(nonnull AMQShortstr *)type
                                  passive:(nonnull AMQBit *)passive
                                  durable:(nonnull AMQBit *)durable
                               autoDelete:(nonnull AMQBit *)autoDelete
                                 internal:(nonnull AMQBit *)internal
                                   noWait:(nonnull AMQBit *)noWait
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.type = type;
        self.passive = passive;
        self.durable = durable;
        self.autoDelete = autoDelete;
        self.internal = internal;
        self.noWait = noWait;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.type,
                                  self.passive,
                                  self.durable,
                                  self.autoDelete,
                                  self.internal,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.exchange = frames[0][1];
        self.type = frames[0][2];
        self.passive = frames[0][3];
        self.durable = frames[0][4];
        self.autoDelete = frames[0][5];
        self.internal = frames[0][6];
        self.noWait = frames[0][7];
        self.arguments = frames[0][8];
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.type,
                                  self.passive,
                                  self.durable,
                                  self.autoDelete,
                                  self.internal,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeDeclareOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeDeclareOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeDelete ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQBit *ifUnused;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeDelete

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                 ifUnused:(nonnull AMQBit *)ifUnused
                                   noWait:(nonnull AMQBit *)noWait {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.ifUnused = ifUnused;
        self.noWait = noWait;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.ifUnused,
                                  self.noWait];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.exchange = frames[0][1];
        self.ifUnused = frames[0][2];
        self.noWait = frames[0][3];
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.ifUnused,
                                  self.noWait];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeDeleteOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeDeleteOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeBind ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *destination;
@property (copy, nonatomic, readwrite) AMQShortstr *source;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeBind

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQTable class]]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                   noWait:(nonnull AMQBit *)noWait
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.destination = destination;
        self.source = source;
        self.routingKey = routingKey;
        self.noWait = noWait;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.destination = frames[0][1];
        self.source = frames[0][2];
        self.routingKey = frames[0][3];
        self.noWait = frames[0][4];
        self.arguments = frames[0][5];
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeBindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeBindOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeUnbind ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *destination;
@property (copy, nonatomic, readwrite) AMQShortstr *source;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeUnbind

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQTable class]]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                   noWait:(nonnull AMQBit *)noWait
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.destination = destination;
        self.source = source;
        self.routingKey = routingKey;
        self.noWait = noWait;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.destination = frames[0][1];
        self.source = frames[0][2];
        self.routingKey = frames[0][3];
        self.noWait = frames[0][4];
        self.arguments = frames[0][5];
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolExchangeUnbindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolExchangeUnbindOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @51; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueDeclare ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQBit *passive;
@property (copy, nonatomic, readwrite) AMQBit *durable;
@property (copy, nonatomic, readwrite) AMQBit *exclusive;
@property (copy, nonatomic, readwrite) AMQBit *autoDelete;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueDeclare

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQTable class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  passive:(nonnull AMQBit *)passive
                                  durable:(nonnull AMQBit *)durable
                                exclusive:(nonnull AMQBit *)exclusive
                               autoDelete:(nonnull AMQBit *)autoDelete
                                   noWait:(nonnull AMQBit *)noWait
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.passive = passive;
        self.durable = durable;
        self.exclusive = exclusive;
        self.autoDelete = autoDelete;
        self.noWait = noWait;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.passive,
                                  self.durable,
                                  self.exclusive,
                                  self.autoDelete,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.queue = frames[0][1];
        self.passive = frames[0][2];
        self.durable = frames[0][3];
        self.exclusive = frames[0][4];
        self.autoDelete = frames[0][5];
        self.noWait = frames[0][6];
        self.arguments = frames[0][7];
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.passive,
                                  self.durable,
                                  self.exclusive,
                                  self.autoDelete,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueDeclareOk ()
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQLong *messageCount;
@property (copy, nonatomic, readwrite) AMQLong *consumerCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueDeclareOk

+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQLong class],
               [AMQLong class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithQueue:(nonnull AMQShortstr *)queue
                         messageCount:(nonnull AMQLong *)messageCount
                        consumerCount:(nonnull AMQLong *)consumerCount {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.messageCount = messageCount;
        self.consumerCount = consumerCount;
        self.payloadArguments = @[self.queue,
                                  self.messageCount,
                                  self.consumerCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.queue = frames[0][0];
        self.messageCount = frames[0][1];
        self.consumerCount = frames[0][2];
        self.payloadArguments = @[self.queue,
                                  self.messageCount,
                                  self.consumerCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueBind ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueBind

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQTable class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                   noWait:(nonnull AMQBit *)noWait
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.noWait = noWait;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.queue = frames[0][1];
        self.exchange = frames[0][2];
        self.routingKey = frames[0][3];
        self.noWait = frames[0][4];
        self.arguments = frames[0][5];
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueBindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueBindOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueUnbind ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueUnbind

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQTable class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @50; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.queue = frames[0][1];
        self.exchange = frames[0][2];
        self.routingKey = frames[0][3];
        self.arguments = frames[0][4];
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueUnbindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueUnbindOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @51; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueuePurge ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueuePurge

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                   noWait:(nonnull AMQBit *)noWait {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.noWait = noWait;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.noWait];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.queue = frames[0][1];
        self.noWait = frames[0][2];
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.noWait];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueuePurgeOk ()
@property (copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueuePurgeOk

+ (NSArray *)frames {
    return @[@[[AMQLong class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.messageCount = frames[0][0];
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueDelete ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQBit *ifUnused;
@property (copy, nonatomic, readwrite) AMQBit *ifEmpty;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueDelete

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 ifUnused:(nonnull AMQBit *)ifUnused
                                  ifEmpty:(nonnull AMQBit *)ifEmpty
                                   noWait:(nonnull AMQBit *)noWait {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.ifUnused = ifUnused;
        self.ifEmpty = ifEmpty;
        self.noWait = noWait;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.ifUnused,
                                  self.ifEmpty,
                                  self.noWait];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.queue = frames[0][1];
        self.ifUnused = frames[0][2];
        self.ifEmpty = frames[0][3];
        self.noWait = frames[0][4];
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.ifUnused,
                                  self.ifEmpty,
                                  self.noWait];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolQueueDeleteOk ()
@property (copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolQueueDeleteOk

+ (NSArray *)frames {
    return @[@[[AMQLong class]]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @41; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.messageCount = frames[0][0];
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicQo ()
@property (copy, nonatomic, readwrite) AMQLong *prefetchSize;
@property (copy, nonatomic, readwrite) AMQShort *prefetchCount;
@property (copy, nonatomic, readwrite) AMQBit *global;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicQo

+ (NSArray *)frames {
    return @[@[[AMQLong class],
               [AMQShort class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithPrefetchSize:(nonnull AMQLong *)prefetchSize
                               prefetchCount:(nonnull AMQShort *)prefetchCount
                                      global:(nonnull AMQBit *)global {
    self = [super init];
    if (self) {
        self.prefetchSize = prefetchSize;
        self.prefetchCount = prefetchCount;
        self.global = global;
        self.payloadArguments = @[self.prefetchSize,
                                  self.prefetchCount,
                                  self.global];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.prefetchSize = frames[0][0];
        self.prefetchCount = frames[0][1];
        self.global = frames[0][2];
        self.payloadArguments = @[self.prefetchSize,
                                  self.prefetchCount,
                                  self.global];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicQosOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicQosOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicConsume ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (copy, nonatomic, readwrite) AMQBit *noLocal;
@property (copy, nonatomic, readwrite) AMQBit *noAck;
@property (copy, nonatomic, readwrite) AMQBit *exclusive;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicConsume

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class],
               [AMQTable class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                              consumerTag:(nonnull AMQShortstr *)consumerTag
                                  noLocal:(nonnull AMQBit *)noLocal
                                    noAck:(nonnull AMQBit *)noAck
                                exclusive:(nonnull AMQBit *)exclusive
                                   noWait:(nonnull AMQBit *)noWait
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.consumerTag = consumerTag;
        self.noLocal = noLocal;
        self.noAck = noAck;
        self.exclusive = exclusive;
        self.noWait = noWait;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.consumerTag,
                                  self.noLocal,
                                  self.noAck,
                                  self.exclusive,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.queue = frames[0][1];
        self.consumerTag = frames[0][2];
        self.noLocal = frames[0][3];
        self.noAck = frames[0][4];
        self.exclusive = frames[0][5];
        self.noWait = frames[0][6];
        self.arguments = frames[0][7];
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.consumerTag,
                                  self.noLocal,
                                  self.noAck,
                                  self.exclusive,
                                  self.noWait,
                                  self.arguments];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicConsumeOk ()
@property (copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicConsumeOk

+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.consumerTag = frames[0][0];
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicCancel ()
@property (copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicCancel

+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                     noWait:(nonnull AMQBit *)noWait {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.noWait = noWait;
        self.payloadArguments = @[self.consumerTag,
                                  self.noWait];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.consumerTag = frames[0][0];
        self.noWait = frames[0][1];
        self.payloadArguments = @[self.consumerTag,
                                  self.noWait];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicCancelOk ()
@property (copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicCancelOk

+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.consumerTag = frames[0][0];
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicPublish ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (copy, nonatomic, readwrite) AMQBit *mandatory;
@property (copy, nonatomic, readwrite) AMQBit *immediate;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicPublish

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                mandatory:(nonnull AMQBit *)mandatory
                                immediate:(nonnull AMQBit *)immediate {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.mandatory = mandatory;
        self.immediate = immediate;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.routingKey,
                                  self.mandatory,
                                  self.immediate];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.exchange = frames[0][1];
        self.routingKey = frames[0][2];
        self.mandatory = frames[0][3];
        self.immediate = frames[0][4];
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.routingKey,
                                  self.mandatory,
                                  self.immediate];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicReturn ()
@property (copy, nonatomic, readwrite) AMQShort *replyCode;
@property (copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicReturn

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @50; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey {
    self = [super init];
    if (self) {
        self.replyCode = replyCode;
        self.replyText = replyText;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.replyCode = frames[0][0];
        self.replyText = frames[0][1];
        self.exchange = frames[0][2];
        self.routingKey = frames[0][3];
        self.payloadArguments = @[self.replyCode,
                                  self.replyText,
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicDeliver ()
@property (copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (copy, nonatomic, readwrite) AMQBit *redelivered;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicDeliver

+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQLonglong class],
               [AMQBit class],
               [AMQShortstr class],
               [AMQShortstr class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @60; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                deliveryTag:(nonnull AMQLonglong *)deliveryTag
                                redelivered:(nonnull AMQBit *)redelivered
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.deliveryTag = deliveryTag;
        self.redelivered = redelivered;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.payloadArguments = @[self.consumerTag,
                                  self.deliveryTag,
                                  self.redelivered,
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.consumerTag = frames[0][0];
        self.deliveryTag = frames[0][1];
        self.redelivered = frames[0][2];
        self.exchange = frames[0][3];
        self.routingKey = frames[0][4];
        self.payloadArguments = @[self.consumerTag,
                                  self.deliveryTag,
                                  self.redelivered,
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicGet ()
@property (copy, nonatomic, readwrite) AMQShort *reserved1;
@property (copy, nonatomic, readwrite) AMQShortstr *queue;
@property (copy, nonatomic, readwrite) AMQBit *noAck;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicGet

+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @70; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                    noAck:(nonnull AMQBit *)noAck {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.noAck = noAck;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.noAck];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.queue = frames[0][1];
        self.noAck = frames[0][2];
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.noAck];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicGetOk ()
@property (copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (copy, nonatomic, readwrite) AMQBit *redelivered;
@property (copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicGetOk

+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQLong class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @71; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                redelivered:(nonnull AMQBit *)redelivered
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey
                               messageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.redelivered = redelivered;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.messageCount = messageCount;
        self.payloadArguments = @[self.deliveryTag,
                                  self.redelivered,
                                  self.exchange,
                                  self.routingKey,
                                  self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.deliveryTag = frames[0][0];
        self.redelivered = frames[0][1];
        self.exchange = frames[0][2];
        self.routingKey = frames[0][3];
        self.messageCount = frames[0][4];
        self.payloadArguments = @[self.deliveryTag,
                                  self.redelivered,
                                  self.exchange,
                                  self.routingKey,
                                  self.messageCount];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicGetEmpty ()
@property (copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicGetEmpty

+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @72; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicAck ()
@property (copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (copy, nonatomic, readwrite) AMQBit *multiple;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicAck

+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @80; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                   multiple:(nonnull AMQBit *)multiple {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.multiple = multiple;
        self.payloadArguments = @[self.deliveryTag,
                                  self.multiple];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.deliveryTag = frames[0][0];
        self.multiple = frames[0][1];
        self.payloadArguments = @[self.deliveryTag,
                                  self.multiple];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicReject ()
@property (copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (copy, nonatomic, readwrite) AMQBit *requeue;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicReject

+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @90; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    requeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.requeue = requeue;
        self.payloadArguments = @[self.deliveryTag,
                                  self.requeue];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.deliveryTag = frames[0][0];
        self.requeue = frames[0][1];
        self.payloadArguments = @[self.deliveryTag,
                                  self.requeue];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicRecoverAsync ()
@property (copy, nonatomic, readwrite) AMQBit *requeue;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicRecoverAsync

+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @100; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithRequeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.requeue = requeue;
        self.payloadArguments = @[self.requeue];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.requeue = frames[0][0];
        self.payloadArguments = @[self.requeue];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicRecover ()
@property (copy, nonatomic, readwrite) AMQBit *requeue;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicRecover

+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @110; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithRequeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.requeue = requeue;
        self.payloadArguments = @[self.requeue];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.requeue = frames[0][0];
        self.payloadArguments = @[self.requeue];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicRecoverOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicRecoverOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @111; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolBasicNack ()
@property (copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (copy, nonatomic, readwrite) AMQBit *multiple;
@property (copy, nonatomic, readwrite) AMQBit *requeue;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolBasicNack

+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class],
               [AMQBit class]]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @120; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                   multiple:(nonnull AMQBit *)multiple
                                    requeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.multiple = multiple;
        self.requeue = requeue;
        self.payloadArguments = @[self.deliveryTag,
                                  self.multiple,
                                  self.requeue];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.deliveryTag = frames[0][0];
        self.multiple = frames[0][1];
        self.requeue = frames[0][2];
        self.payloadArguments = @[self.deliveryTag,
                                  self.multiple,
                                  self.requeue];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolTxSelect ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolTxSelect

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolTxSelectOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolTxSelectOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolTxCommit ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolTxCommit

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolTxCommitOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolTxCommitOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolTxRollback ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolTxRollback

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolTxRollbackOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolTxRollbackOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConfirmSelect ()
@property (copy, nonatomic, readwrite) AMQBit *nowait;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConfirmSelect

+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}
- (NSNumber *)classID     { return @85; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }

- (nonnull instancetype)initWithNowait:(nonnull AMQBit *)nowait {
    self = [super init];
    if (self) {
        self.nowait = nowait;
        self.payloadArguments = @[self.nowait];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.nowait = frames[0][0];
        self.payloadArguments = @[self.nowait];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

@interface AMQProtocolConfirmSelectOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@end

@implementation AMQProtocolConfirmSelectOk

+ (NSArray *)frames {
    return @[@[]];
}
- (NSNumber *)classID     { return @85; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.payloadArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.payloadArguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end

