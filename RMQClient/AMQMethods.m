// This file is generated. Do not edit.
#import "AMQMethods.h"

@interface AMQConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *locales;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionStart

+ (NSArray *)frame {
    return @[[AMQOctet class],
               [AMQOctet class],
               [AMQTable class],
               [AMQLongstr class],
               [AMQLongstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @10; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionStartOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *response;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *locale;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionStartOk

+ (NSArray *)frame {
    return @[[AMQTable class],
               [AMQShortstr class],
               [AMQLongstr class],
               [AMQShortstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @11; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionSecure ()
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *challenge;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionSecure

+ (NSArray *)frame {
    return @[[AMQLongstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @20; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionSecureOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *response;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionSecureOk

+ (NSArray *)frame {
    return @[[AMQLongstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @21; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionTune ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionTune

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQLong class],
               [AMQShort class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @30; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionTuneOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *heartbeat;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionTuneOk

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQLong class],
               [AMQShort class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @31; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionOpen ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) AMQConnectionOpenOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionOpen

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @40; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortstr *)virtualHost
                                  reserved1:(nonnull AMQShortstr *)reserved1
                                    options:(AMQConnectionOpenOptions)options {
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

@interface AMQConnectionOpenOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionOpenOk

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @41; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionClose ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionClose

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @50; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return YES; }

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

@interface AMQConnectionCloseOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionCloseOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @51; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return YES; }


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

@interface AMQConnectionBlocked ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reason;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionBlocked

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @60; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQConnectionUnblocked ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConnectionUnblocked

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @10; }
- (NSNumber *)methodID      { return @61; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQChannelOpen ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQChannelOpen

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @10; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQChannelOpenOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQChannelOpenOk

+ (NSArray *)frame {
    return @[[AMQLongstr class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @11; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQChannelFlow ()
@property (nonatomic, readwrite) AMQChannelFlowOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQChannelFlow

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @20; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithOptions:(AMQChannelFlowOptions)options {
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

@interface AMQChannelFlowOk ()
@property (nonatomic, readwrite) AMQChannelFlowOkOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQChannelFlowOk

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @21; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithOptions:(AMQChannelFlowOkOptions)options {
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

@interface AMQChannelClose ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *methodId;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQChannelClose

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @40; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQChannelCloseOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQChannelCloseOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @20; }
- (NSNumber *)methodID      { return @41; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQExchangeDeclare ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *type;
@property (nonatomic, readwrite) AMQExchangeDeclareOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeDeclare

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @10; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                     type:(nonnull AMQShortstr *)type
                                  options:(AMQExchangeDeclareOptions)options
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

@interface AMQExchangeDeclareOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeDeclareOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @11; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQExchangeDelete ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonatomic, readwrite) AMQExchangeDeleteOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeDelete

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @20; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                  options:(AMQExchangeDeleteOptions)options {
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

@interface AMQExchangeDeleteOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeDeleteOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @21; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQExchangeBind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQExchangeBindOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeBind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @30; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQExchangeBindOptions)options
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

@interface AMQExchangeBindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeBindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @31; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQExchangeUnbind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQExchangeUnbindOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeUnbind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @40; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQExchangeUnbindOptions)options
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

@interface AMQExchangeUnbindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQExchangeUnbindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @40; }
- (NSNumber *)methodID      { return @51; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQQueueDeclare ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQQueueDeclareOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueDeclare

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @10; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQQueueDeclareOptions)options
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

@interface AMQQueueDeclareOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *consumerCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueDeclareOk

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQLong class],
               [AMQLong class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @11; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQQueueBind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQQueueBindOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueBind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @20; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQQueueBindOptions)options
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

@interface AMQQueueBindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueBindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @21; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQQueueUnbind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueUnbind

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQTable class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @50; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQQueueUnbindOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueUnbindOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @51; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQQueuePurge ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQQueuePurgeOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueuePurge

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @30; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQQueuePurgeOptions)options {
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

@interface AMQQueuePurgeOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueuePurgeOk

+ (NSArray *)frame {
    return @[[AMQLong class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @31; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQQueueDelete ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQQueueDeleteOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueDelete

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @40; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQQueueDeleteOptions)options {
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

@interface AMQQueueDeleteOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQQueueDeleteOk

+ (NSArray *)frame {
    return @[[AMQLong class]];
}
- (NSNumber *)classID       { return @50; }
- (NSNumber *)methodID      { return @41; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQBasicQos ()
@property (nonnull, copy, nonatomic, readwrite) AMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *prefetchCount;
@property (nonatomic, readwrite) AMQBasicQosOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicQos

+ (NSArray *)frame {
    return @[[AMQLong class],
               [AMQShort class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @10; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithPrefetchSize:(nonnull AMQLong *)prefetchSize
                               prefetchCount:(nonnull AMQShort *)prefetchCount
                                     options:(AMQBasicQosOptions)options {
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

@interface AMQBasicQosOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicQosOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @11; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQBasicConsume ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) AMQBasicConsumeOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicConsume

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class],
               [AMQTable class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @20; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                              consumerTag:(nonnull AMQShortstr *)consumerTag
                                  options:(AMQBasicConsumeOptions)options
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

@interface AMQBasicConsumeOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicConsumeOk

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @21; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQBasicCancel ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) AMQBasicCancelOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicCancel

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @30; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                    options:(AMQBasicCancelOptions)options {
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

@interface AMQBasicCancelOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicCancelOk

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @31; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQBasicPublish ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) AMQBasicPublishOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicPublish

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @40; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQBasicPublishOptions)options {
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

@interface AMQBasicReturn ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicReturn

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @50; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQBasicDeliver ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQBasicDeliverOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicDeliver

+ (NSArray *)frame {
    return @[[AMQShortstr class],
               [AMQLonglong class],
               [AMQOctet class],
               [AMQShortstr class],
               [AMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @60; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                deliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicDeliverOptions)options
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

@interface AMQBasicGet ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonatomic, readwrite) AMQBasicGetOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicGet

+ (NSArray *)frame {
    return @[[AMQShort class],
               [AMQShortstr class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @70; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQBasicGetOptions)options {
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

@interface AMQBasicGetOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQBasicGetOkOptions options;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicGetOk

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQLong class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @71; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return YES; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicGetOkOptions)options
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

@interface AMQBasicGetEmpty ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicGetEmpty

+ (NSArray *)frame {
    return @[[AMQShortstr class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @72; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

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

@interface AMQBasicAck ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQBasicAckOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicAck

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @80; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicAckOptions)options {
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

@interface AMQBasicReject ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQBasicRejectOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicReject

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @90; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicRejectOptions)options {
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

@interface AMQBasicRecoverAsync ()
@property (nonatomic, readwrite) AMQBasicRecoverAsyncOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicRecoverAsync

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @100; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithOptions:(AMQBasicRecoverAsyncOptions)options {
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

@interface AMQBasicRecover ()
@property (nonatomic, readwrite) AMQBasicRecoverOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicRecover

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @110; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithOptions:(AMQBasicRecoverOptions)options {
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

@interface AMQBasicRecoverOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicRecoverOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @111; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQBasicNack ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonatomic, readwrite) AMQBasicNackOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQBasicNack

+ (NSArray *)frame {
    return @[[AMQLonglong class],
               [AMQOctet class]];
}
- (NSNumber *)classID       { return @60; }
- (NSNumber *)methodID      { return @120; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicNackOptions)options {
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

@interface AMQTxSelect ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQTxSelect

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @10; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQTxSelectOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQTxSelectOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @11; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQTxCommit ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQTxCommit

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @20; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQTxCommitOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQTxCommitOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @21; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQTxRollback ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQTxRollback

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @30; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQTxRollbackOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQTxRollbackOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @90; }
- (NSNumber *)methodID      { return @31; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

@interface AMQConfirmSelect ()
@property (nonatomic, readwrite) AMQConfirmSelectOptions options;
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConfirmSelect

+ (NSArray *)frame {
    return @[[AMQOctet class]];
}
- (NSNumber *)classID       { return @85; }
- (NSNumber *)methodID      { return @10; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }

- (nonnull instancetype)initWithOptions:(AMQConfirmSelectOptions)options {
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

@interface AMQConfirmSelectOk ()
@property (nonatomic, readwrite) NSArray *payloadArguments;
@property (nonatomic, readwrite) BOOL hasContent;
@end

@implementation AMQConfirmSelectOk

+ (NSArray *)frame {
    return @[];
}
- (NSNumber *)classID       { return @85; }
- (NSNumber *)methodID      { return @11; }
- (NSNumber *)frameTypeID   { return @1; }
- (BOOL)hasContent          { return NO; }
- (BOOL)shouldHaltOnReceipt { return NO; }


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

