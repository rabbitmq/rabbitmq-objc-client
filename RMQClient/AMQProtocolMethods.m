// This file is generated. Do not edit.
#import "AMQProtocolMethods.h"

@interface AMQProtocolConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *locales;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionStart

+ (NSArray *)frame {
    return @[[AMQOctet class],
               [AMQOctet class],
               [AMQTable class],
               [AMQLongstr class],
               [AMQLongstr class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.versionMajor = ((AMQOctet *)frame[0]);
        self.versionMinor = ((AMQOctet *)frame[1]);
        self.serverProperties = ((AMQTable *)frame[2]);
        self.mechanisms = ((AMQLongstr *)frame[3]);
        self.locales = ((AMQLongstr *)frame[4]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *response;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *locale;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionStartOk

+ (NSArray *)frame {
    return @[[AMQTable class],
               [AMQShortstr class],
               [AMQLongstr class],
               [AMQShortstr class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.clientProperties = ((AMQTable *)frame[0]);
        self.mechanism = ((AMQShortstr *)frame[1]);
        self.response = ((AMQLongstr *)frame[2]);
        self.locale = ((AMQShortstr *)frame[3]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *challenge;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionSecure

+ (NSArray *)frame {
    return @[[AMQLongstr class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithChallenge:(nonnull AMQLongstr *)challenge {
    self = [super init];
    if (self) {
        self.challenge = challenge;
        self.payloadArguments = @[self.challenge];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.challenge = ((AMQLongstr *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *response;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionSecureOk

+ (NSArray *)frame {
    return @[[AMQLongstr class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithResponse:(nonnull AMQLongstr *)response {
    self = [super init];
    if (self) {
        self.response = response;
        self.payloadArguments = @[self.response];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.response = ((AMQLongstr *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionTune

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQLong class],
               [AMQShort class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.channelMax = ((AMQShort *)frame[0]);
        self.frameMax = ((AMQLong *)frame[1]);
        self.heartbeat = ((AMQShort *)frame[2]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionTuneOk

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQLong class],
               [AMQShort class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.channelMax = ((AMQShort *)frame[0]);
        self.frameMax = ((AMQLong *)frame[1]);
        self.heartbeat = ((AMQShort *)frame[2]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) AMQProtocolConnectionOpenOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionOpen

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortstr *)virtualHost
                                  reserved1:(nonnull AMQShortstr *)reserved1
                                    options:(AMQProtocolConnectionOpenOptions)options {
    self = [super init];
    if (self) {
        self.virtualHost = virtualHost;
        self.reserved1 = reserved1;
        self.options = options;
        self.payloadArguments = @[self.virtualHost,
                                  self.reserved1,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.virtualHost = ((AMQShortstr *)frame[0]);
        self.reserved1 = ((AMQShortstr *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.virtualHost,
                                  self.reserved1,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionOpenOk

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @41; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShortstr *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionClose

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @50; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.replyCode = ((AMQShort *)frame[0]);
        self.replyText = ((AMQShortstr *)frame[1]);
        self.classId = ((AMQShort *)frame[2]);
        self.methodId = ((AMQShort *)frame[3]);
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionCloseOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @51; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reason;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionBlocked

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @60; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReason:(nonnull AMQShortstr *)reason {
    self = [super init];
    if (self) {
        self.reason = reason;
        self.payloadArguments = @[self.reason];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reason = ((AMQShortstr *)frame[0]);
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConnectionUnblocked

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @10; }
- (NSNumber *)methodID    { return @61; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolChannelOpen

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShortstr *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolChannelOpenOk

+ (NSArray *)frame {
    return @[[AMQLongstr class]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQLongstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQLongstr *)frame[0]);
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
@property (nonatomic, readwrite) AMQProtocolChannelFlowOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolChannelFlow

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithOptions:(AMQProtocolChannelFlowOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((AMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) AMQProtocolChannelFlowOkOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolChannelFlowOk

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithOptions:(AMQProtocolChannelFlowOkOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((AMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolChannelClose

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.replyCode = ((AMQShort *)frame[0]);
        self.replyText = ((AMQShortstr *)frame[1]);
        self.classId = ((AMQShort *)frame[2]);
        self.methodId = ((AMQShort *)frame[3]);
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolChannelCloseOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @20; }
- (NSNumber *)methodID    { return @41; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *type;
@property (nonatomic, readwrite) AMQProtocolExchangeDeclareOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeDeclare

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                     type:(nonnull AMQShortstr *)type
                                  options:(AMQProtocolExchangeDeclareOptions)options
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.type = type;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.type,
                                  [[AMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.exchange = ((AMQShortstr *)frame[1]);
        self.type = ((AMQShortstr *)frame[2]);
        self.options = ((AMQOctet *)frame[3]).integerValue;
        self.arguments = ((AMQTable *)frame[4]);
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.type,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeDeclareOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonatomic, readwrite) AMQProtocolExchangeDeleteOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeDelete

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                  options:(AMQProtocolExchangeDeleteOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.exchange = ((AMQShortstr *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeDeleteOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQProtocolExchangeBindOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeBind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQProtocolExchangeBindOptions)options
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.destination = destination;
        self.source = source;
        self.routingKey = routingKey;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.destination = ((AMQShortstr *)frame[1]);
        self.source = ((AMQShortstr *)frame[2]);
        self.routingKey = ((AMQShortstr *)frame[3]);
        self.options = ((AMQOctet *)frame[4]).integerValue;
        self.arguments = ((AMQTable *)frame[5]);
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeBindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQProtocolExchangeUnbindOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeUnbind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQProtocolExchangeUnbindOptions)options
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.destination = destination;
        self.source = source;
        self.routingKey = routingKey;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.destination = ((AMQShortstr *)frame[1]);
        self.source = ((AMQShortstr *)frame[2]);
        self.routingKey = ((AMQShortstr *)frame[3]);
        self.options = ((AMQOctet *)frame[4]).integerValue;
        self.arguments = ((AMQTable *)frame[5]);
        self.payloadArguments = @[self.reserved1,
                                  self.destination,
                                  self.source,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolExchangeUnbindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @40; }
- (NSNumber *)methodID    { return @51; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQProtocolQueueDeclareOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueDeclare

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQProtocolQueueDeclareOptions)options
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.queue = ((AMQShortstr *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.arguments = ((AMQTable *)frame[3]);
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *consumerCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueDeclareOk

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQLong class],
               [AMQLong class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.queue = ((AMQShortstr *)frame[0]);
        self.messageCount = ((AMQLong *)frame[1]);
        self.consumerCount = ((AMQLong *)frame[2]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQProtocolQueueBindOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueBind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQProtocolQueueBindOptions)options
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.queue = ((AMQShortstr *)frame[1]);
        self.exchange = ((AMQShortstr *)frame[2]);
        self.routingKey = ((AMQShortstr *)frame[3]);
        self.options = ((AMQOctet *)frame[4]).integerValue;
        self.arguments = ((AMQTable *)frame[5]);
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.exchange,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueBindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueUnbind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQTable class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @50; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.queue = ((AMQShortstr *)frame[1]);
        self.exchange = ((AMQShortstr *)frame[2]);
        self.routingKey = ((AMQShortstr *)frame[3]);
        self.arguments = ((AMQTable *)frame[4]);
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueUnbindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @51; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQProtocolQueuePurgeOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueuePurge

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQProtocolQueuePurgeOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.queue = ((AMQShortstr *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueuePurgeOk

+ (NSArray *)frame {
    return @[[AMQLong class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.messageCount = ((AMQLong *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQProtocolQueueDeleteOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueDelete

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQProtocolQueueDeleteOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.queue = ((AMQShortstr *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolQueueDeleteOk

+ (NSArray *)frame {
    return @[[AMQLong class]];
}
- (NSNumber *)classID     { return @50; }
- (NSNumber *)methodID    { return @41; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.payloadArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.messageCount = ((AMQLong *)frame[0]);
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

@interface AMQProtocolBasicQos ()
@property (nonnull, copy, nonatomic, readwrite) AMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *prefetchCount;
@property (nonatomic, readwrite) AMQProtocolBasicQosOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicQos

+ (NSArray *)frame {
    return @[[AMQLong class],
               [AMQShort class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithPrefetchSize:(nonnull AMQLong *)prefetchSize
                               prefetchCount:(nonnull AMQShort *)prefetchCount
                                     options:(AMQProtocolBasicQosOptions)options {
    self = [super init];
    if (self) {
        self.prefetchSize = prefetchSize;
        self.prefetchCount = prefetchCount;
        self.options = options;
        self.payloadArguments = @[self.prefetchSize,
                                  self.prefetchCount,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.prefetchSize = ((AMQLong *)frame[0]);
        self.prefetchCount = ((AMQShort *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.prefetchSize,
                                  self.prefetchCount,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicQosOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) AMQProtocolBasicConsumeOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicConsume

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                              consumerTag:(nonnull AMQShortstr *)consumerTag
                                  options:(AMQProtocolBasicConsumeOptions)options
                                arguments:(nonnull AMQTable *)arguments {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.consumerTag = consumerTag;
        self.options = options;
        self.arguments = arguments;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.consumerTag,
                                  [[AMQOctet alloc] init:self.options],
                                  self.arguments];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.queue = ((AMQShortstr *)frame[1]);
        self.consumerTag = ((AMQShortstr *)frame[2]);
        self.options = ((AMQOctet *)frame[3]).integerValue;
        self.arguments = ((AMQTable *)frame[4]);
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  self.consumerTag,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicConsumeOk

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((AMQShortstr *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) AMQProtocolBasicCancelOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicCancel

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                    options:(AMQProtocolBasicCancelOptions)options {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.options = options;
        self.payloadArguments = @[self.consumerTag,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((AMQShortstr *)frame[0]);
        self.options = ((AMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.consumerTag,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicCancelOk

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.payloadArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((AMQShortstr *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQProtocolBasicPublishOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicPublish

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @40; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return YES; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQProtocolBasicPublishOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.exchange = ((AMQShortstr *)frame[1]);
        self.routingKey = ((AMQShortstr *)frame[2]);
        self.options = ((AMQOctet *)frame[3]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.exchange,
                                  self.routingKey,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicReturn

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @50; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return YES; }

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

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.replyCode = ((AMQShort *)frame[0]);
        self.replyText = ((AMQShortstr *)frame[1]);
        self.exchange = ((AMQShortstr *)frame[2]);
        self.routingKey = ((AMQShortstr *)frame[3]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQProtocolBasicDeliverOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicDeliver

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQLonglong class],
               [AMQOctet class],
               [AMQShortstr class],
               [AMQShortstr class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @60; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return YES; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                deliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicDeliverOptions)options
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.payloadArguments = @[self.consumerTag,
                                  self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options],
                                  self.exchange,
                                  self.routingKey];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.consumerTag = ((AMQShortstr *)frame[0]);
        self.deliveryTag = ((AMQLonglong *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.exchange = ((AMQShortstr *)frame[3]);
        self.routingKey = ((AMQShortstr *)frame[4]);
        self.payloadArguments = @[self.consumerTag,
                                  self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQProtocolBasicGetOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicGet

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @70; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQProtocolBasicGetOptions)options {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.options = options;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShort *)frame[0]);
        self.queue = ((AMQShortstr *)frame[1]);
        self.options = ((AMQOctet *)frame[2]).integerValue;
        self.payloadArguments = @[self.reserved1,
                                  self.queue,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQProtocolBasicGetOkOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicGetOk

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQLong class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @71; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return YES; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicGetOkOptions)options
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey
                               messageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.exchange = exchange;
        self.routingKey = routingKey;
        self.messageCount = messageCount;
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options],
                                  self.exchange,
                                  self.routingKey,
                                  self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((AMQLonglong *)frame[0]);
        self.options = ((AMQOctet *)frame[1]).integerValue;
        self.exchange = ((AMQShortstr *)frame[2]);
        self.routingKey = ((AMQShortstr *)frame[3]);
        self.messageCount = ((AMQLong *)frame[4]);
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options],
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
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicGetEmpty

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @72; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.payloadArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.reserved1 = ((AMQShortstr *)frame[0]);
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
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQProtocolBasicAckOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicAck

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @80; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicAckOptions)options {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((AMQLonglong *)frame[0]);
        self.options = ((AMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQProtocolBasicRejectOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicReject

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @90; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicRejectOptions)options {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((AMQLonglong *)frame[0]);
        self.options = ((AMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) AMQProtocolBasicRecoverAsyncOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicRecoverAsync

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @100; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithOptions:(AMQProtocolBasicRecoverAsyncOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((AMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) AMQProtocolBasicRecoverOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicRecover

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @110; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithOptions:(AMQProtocolBasicRecoverOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((AMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicRecoverOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @111; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQProtocolBasicNackOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolBasicNack

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class]];
}
- (NSNumber *)classID     { return @60; }
- (NSNumber *)methodID    { return @120; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicNackOptions)options {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.options = options;
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.deliveryTag = ((AMQLonglong *)frame[0]);
        self.options = ((AMQOctet *)frame[1]).integerValue;
        self.payloadArguments = @[self.deliveryTag,
                                  [[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolTxSelect

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolTxSelectOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolTxCommit

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @20; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolTxCommitOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @21; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolTxRollback

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @30; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolTxRollbackOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @90; }
- (NSNumber *)methodID    { return @31; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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
@property (nonatomic, readwrite) AMQProtocolConfirmSelectOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConfirmSelect

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID     { return @85; }
- (NSNumber *)methodID    { return @10; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }

- (nonnull instancetype)initWithOptions:(AMQProtocolConfirmSelectOptions)options {
    self = [super init];
    if (self) {
        self.options = options;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
    }
    return self;
}

- (instancetype)initWithDecodedFrame:(NSArray *)frame {
    self = [super init];
    if (self) {
        self.options = ((AMQOctet *)frame[0]).integerValue;
        self.payloadArguments = @[[[AMQOctet alloc] init:self.options]];
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
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQProtocolConfirmSelectOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID     { return @85; }
- (NSNumber *)methodID    { return @11; }
- (NSNumber *)frameTypeID { return @1; }
- (BOOL)hasContent        { return NO; }


- (instancetype)initWithDecodedFrame:(NSArray *)frame {
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

