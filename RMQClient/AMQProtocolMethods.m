// This file is generated. Do not edit.
#import "AMQProtocolMethods.h"

@interface AMQProtocolConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *locales;
@end

@implementation AMQProtocolConnectionStart
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(10); }
+ (NSArray *)frames {
    return @[@[[AMQOctet class],
               [AMQOctet class],
               [AMQTable class],
               [AMQLongstr class],
               [AMQLongstr class]]];
}

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
        self.frameArguments = @[self.versionMajor,
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
        self.frameArguments = @[self.versionMajor,
                                self.versionMinor,
                                self.serverProperties,
                                self.mechanisms,
                                self.locales];
    }
    return self;
}

@end

@interface AMQProtocolConnectionStartOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *response;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *locale;
@end

@implementation AMQProtocolConnectionStartOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(11); }
+ (NSArray *)frames {
    return @[@[[AMQTable class],
               [AMQShortstr class],
               [AMQLongstr class],
               [AMQShortstr class]]];
}

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
        self.frameArguments = @[self.clientProperties,
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
        self.frameArguments = @[self.clientProperties,
                                self.mechanism,
                                self.response,
                                self.locale];
    }
    return self;
}

@end

@interface AMQProtocolConnectionSecure ()
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *challenge;
@end

@implementation AMQProtocolConnectionSecure
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(20); }
+ (NSArray *)frames {
    return @[@[[AMQLongstr class]]];
}

- (nonnull instancetype)initWithChallenge:(nonnull AMQLongstr *)challenge {
    self = [super init];
    if (self) {
        self.challenge = challenge;
        self.frameArguments = @[self.challenge];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.challenge = frames[0][0];
        self.frameArguments = @[self.challenge];
    }
    return self;
}

@end

@interface AMQProtocolConnectionSecureOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *response;
@end

@implementation AMQProtocolConnectionSecureOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(21); }
+ (NSArray *)frames {
    return @[@[[AMQLongstr class]]];
}

- (nonnull instancetype)initWithResponse:(nonnull AMQLongstr *)response {
    self = [super init];
    if (self) {
        self.response = response;
        self.frameArguments = @[self.response];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.response = frames[0][0];
        self.frameArguments = @[self.response];
    }
    return self;
}

@end

@interface AMQProtocolConnectionTune ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *heartbeat;
@end

@implementation AMQProtocolConnectionTune
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(30); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQLong class],
               [AMQShort class]]];
}

- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.frameArguments = @[self.channelMax,
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
        self.frameArguments = @[self.channelMax,
                                self.frameMax,
                                self.heartbeat];
    }
    return self;
}

@end

@interface AMQProtocolConnectionTuneOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *heartbeat;
@end

@implementation AMQProtocolConnectionTuneOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(31); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQLong class],
               [AMQShort class]]];
}

- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.frameArguments = @[self.channelMax,
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
        self.frameArguments = @[self.channelMax,
                                self.frameMax,
                                self.heartbeat];
    }
    return self;
}

@end

@interface AMQProtocolConnectionOpen ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *reserved2;
@end

@implementation AMQProtocolConnectionOpen
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(40); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortstr *)virtualHost
                                  reserved1:(nonnull AMQShortstr *)reserved1
                                  reserved2:(nonnull AMQBit *)reserved2 {
    self = [super init];
    if (self) {
        self.virtualHost = virtualHost;
        self.reserved1 = reserved1;
        self.reserved2 = reserved2;
        self.frameArguments = @[self.virtualHost,
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
        self.frameArguments = @[self.virtualHost,
                                self.reserved1,
                                self.reserved2];
    }
    return self;
}

@end

@interface AMQProtocolConnectionOpenOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@end

@implementation AMQProtocolConnectionOpenOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(41); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

@end

@interface AMQProtocolConnectionClose ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *methodId;
@end

@implementation AMQProtocolConnectionClose
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(50); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]]];
}

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
        self.frameArguments = @[self.replyCode,
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
        self.frameArguments = @[self.replyCode,
                                self.replyText,
                                self.classId,
                                self.methodId];
    }
    return self;
}

@end

@interface AMQProtocolConnectionCloseOk ()
@end

@implementation AMQProtocolConnectionCloseOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(51); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolConnectionBlocked ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reason;
@end

@implementation AMQProtocolConnectionBlocked
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(60); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}

- (nonnull instancetype)initWithReason:(nonnull AMQShortstr *)reason {
    self = [super init];
    if (self) {
        self.reason = reason;
        self.frameArguments = @[self.reason];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reason = frames[0][0];
        self.frameArguments = @[self.reason];
    }
    return self;
}

@end

@interface AMQProtocolConnectionUnblocked ()
@end

@implementation AMQProtocolConnectionUnblocked
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(61); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolChannelOpen ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@end

@implementation AMQProtocolChannelOpen
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(10); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

@end

@interface AMQProtocolChannelOpenOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *reserved1;
@end

@implementation AMQProtocolChannelOpenOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(11); }
+ (NSArray *)frames {
    return @[@[[AMQLongstr class]]];
}

- (nonnull instancetype)initWithReserved1:(nonnull AMQLongstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

@end

@interface AMQProtocolChannelFlow ()
@property (nonnull, copy, nonatomic, readwrite) AMQBit *active;
@end

@implementation AMQProtocolChannelFlow
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(20); }
+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}

- (nonnull instancetype)initWithActive:(nonnull AMQBit *)active {
    self = [super init];
    if (self) {
        self.active = active;
        self.frameArguments = @[self.active];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.active = frames[0][0];
        self.frameArguments = @[self.active];
    }
    return self;
}

@end

@interface AMQProtocolChannelFlowOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQBit *active;
@end

@implementation AMQProtocolChannelFlowOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(21); }
+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}

- (nonnull instancetype)initWithActive:(nonnull AMQBit *)active {
    self = [super init];
    if (self) {
        self.active = active;
        self.frameArguments = @[self.active];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.active = frames[0][0];
        self.frameArguments = @[self.active];
    }
    return self;
}

@end

@interface AMQProtocolChannelClose ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *classId;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *methodId;
@end

@implementation AMQProtocolChannelClose
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(40); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShort class],
               [AMQShort class]]];
}

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
        self.frameArguments = @[self.replyCode,
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
        self.frameArguments = @[self.replyCode,
                                self.replyText,
                                self.classId,
                                self.methodId];
    }
    return self;
}

@end

@interface AMQProtocolChannelCloseOk ()
@end

@implementation AMQProtocolChannelCloseOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(41); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolExchangeDeclare ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *type;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *passive;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *durable;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *autoDelete;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *internal;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@end

@implementation AMQProtocolExchangeDeclare
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(10); }
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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
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

@end

@interface AMQProtocolExchangeDeclareOk ()
@end

@implementation AMQProtocolExchangeDeclareOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(11); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolExchangeDelete ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *ifUnused;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@end

@implementation AMQProtocolExchangeDelete
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(20); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class]]];
}

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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.exchange,
                                self.ifUnused,
                                self.noWait];
    }
    return self;
}

@end

@interface AMQProtocolExchangeDeleteOk ()
@end

@implementation AMQProtocolExchangeDeleteOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(21); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolExchangeBind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@end

@implementation AMQProtocolExchangeBind
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(30); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQTable class]]];
}

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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.destination,
                                self.source,
                                self.routingKey,
                                self.noWait,
                                self.arguments];
    }
    return self;
}

@end

@interface AMQProtocolExchangeBindOk ()
@end

@implementation AMQProtocolExchangeBindOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(31); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolExchangeUnbind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@end

@implementation AMQProtocolExchangeUnbind
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(40); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQTable class]]];
}

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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.destination,
                                self.source,
                                self.routingKey,
                                self.noWait,
                                self.arguments];
    }
    return self;
}

@end

@interface AMQProtocolExchangeUnbindOk ()
@end

@implementation AMQProtocolExchangeUnbindOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(40); }
+ (NSNumber *)methodID { return @(51); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolQueueDeclare ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *passive;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *durable;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *exclusive;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *autoDelete;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@end

@implementation AMQProtocolQueueDeclare
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(10); }
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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
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

@end

@interface AMQProtocolQueueDeclareOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *consumerCount;
@end

@implementation AMQProtocolQueueDeclareOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(11); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQLong class],
               [AMQLong class]]];
}

- (nonnull instancetype)initWithQueue:(nonnull AMQShortstr *)queue
                         messageCount:(nonnull AMQLong *)messageCount
                        consumerCount:(nonnull AMQLong *)consumerCount {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.messageCount = messageCount;
        self.consumerCount = consumerCount;
        self.frameArguments = @[self.queue,
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
        self.frameArguments = @[self.queue,
                                self.messageCount,
                                self.consumerCount];
    }
    return self;
}

@end

@interface AMQProtocolQueueBind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@end

@implementation AMQProtocolQueueBind
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(20); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQTable class]]];
}

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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.queue,
                                self.exchange,
                                self.routingKey,
                                self.noWait,
                                self.arguments];
    }
    return self;
}

@end

@interface AMQProtocolQueueBindOk ()
@end

@implementation AMQProtocolQueueBindOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(21); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolQueueUnbind ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@end

@implementation AMQProtocolQueueUnbind
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(50); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQTable class]]];
}

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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.queue,
                                self.exchange,
                                self.routingKey,
                                self.arguments];
    }
    return self;
}

@end

@interface AMQProtocolQueueUnbindOk ()
@end

@implementation AMQProtocolQueueUnbindOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(51); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolQueuePurge ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@end

@implementation AMQProtocolQueuePurge
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(30); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                   noWait:(nonnull AMQBit *)noWait {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.noWait = noWait;
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.queue,
                                self.noWait];
    }
    return self;
}

@end

@interface AMQProtocolQueuePurgeOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@end

@implementation AMQProtocolQueuePurgeOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(31); }
+ (NSArray *)frames {
    return @[@[[AMQLong class]]];
}

- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.frameArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.messageCount = frames[0][0];
        self.frameArguments = @[self.messageCount];
    }
    return self;
}

@end

@interface AMQProtocolQueueDelete ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *ifUnused;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *ifEmpty;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@end

@implementation AMQProtocolQueueDelete
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(40); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class],
               [AMQBit class]]];
}

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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.queue,
                                self.ifUnused,
                                self.ifEmpty,
                                self.noWait];
    }
    return self;
}

@end

@interface AMQProtocolQueueDeleteOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@end

@implementation AMQProtocolQueueDeleteOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(50); }
+ (NSNumber *)methodID { return @(41); }
+ (NSArray *)frames {
    return @[@[[AMQLong class]]];
}

- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount {
    self = [super init];
    if (self) {
        self.messageCount = messageCount;
        self.frameArguments = @[self.messageCount];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.messageCount = frames[0][0];
        self.frameArguments = @[self.messageCount];
    }
    return self;
}

@end

@interface AMQProtocolBasicQo ()
@property (nonnull, copy, nonatomic, readwrite) AMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readwrite) AMQShort *prefetchCount;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *global;
@end

@implementation AMQProtocolBasicQo
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(10); }
+ (NSArray *)frames {
    return @[@[[AMQLong class],
               [AMQShort class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithPrefetchSize:(nonnull AMQLong *)prefetchSize
                               prefetchCount:(nonnull AMQShort *)prefetchCount
                                      global:(nonnull AMQBit *)global {
    self = [super init];
    if (self) {
        self.prefetchSize = prefetchSize;
        self.prefetchCount = prefetchCount;
        self.global = global;
        self.frameArguments = @[self.prefetchSize,
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
        self.frameArguments = @[self.prefetchSize,
                                self.prefetchCount,
                                self.global];
    }
    return self;
}

@end

@interface AMQProtocolBasicQosOk ()
@end

@implementation AMQProtocolBasicQosOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(11); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolBasicConsume ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noLocal;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noAck;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *exclusive;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *arguments;
@end

@implementation AMQProtocolBasicConsume
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(20); }
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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
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

@end

@interface AMQProtocolBasicConsumeOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@end

@implementation AMQProtocolBasicConsumeOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(21); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.frameArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.consumerTag = frames[0][0];
        self.frameArguments = @[self.consumerTag];
    }
    return self;
}

@end

@interface AMQProtocolBasicCancel ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noWait;
@end

@implementation AMQProtocolBasicCancel
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(30); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                     noWait:(nonnull AMQBit *)noWait {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.noWait = noWait;
        self.frameArguments = @[self.consumerTag,
                                self.noWait];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.consumerTag = frames[0][0];
        self.noWait = frames[0][1];
        self.frameArguments = @[self.consumerTag,
                                self.noWait];
    }
    return self;
}

@end

@interface AMQProtocolBasicCancelOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@end

@implementation AMQProtocolBasicCancelOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(31); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}

- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag {
    self = [super init];
    if (self) {
        self.consumerTag = consumerTag;
        self.frameArguments = @[self.consumerTag];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.consumerTag = frames[0][0];
        self.frameArguments = @[self.consumerTag];
    }
    return self;
}

@end

@interface AMQProtocolBasicPublish ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *mandatory;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *immediate;
@end

@implementation AMQProtocolBasicPublish
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(40); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQBit class],
               [AMQBit class]]];
}

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
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.exchange,
                                self.routingKey,
                                self.mandatory,
                                self.immediate];
    }
    return self;
}

@end

@interface AMQProtocolBasicReturn ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@end

@implementation AMQProtocolBasicReturn
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(50); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQShortstr class]]];
}

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
        self.frameArguments = @[self.replyCode,
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
        self.frameArguments = @[self.replyCode,
                                self.replyText,
                                self.exchange,
                                self.routingKey];
    }
    return self;
}

@end

@interface AMQProtocolBasicDeliver ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *redelivered;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@end

@implementation AMQProtocolBasicDeliver
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(60); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class],
               [AMQLonglong class],
               [AMQBit class],
               [AMQShortstr class],
               [AMQShortstr class]]];
}

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
        self.frameArguments = @[self.consumerTag,
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
        self.frameArguments = @[self.consumerTag,
                                self.deliveryTag,
                                self.redelivered,
                                self.exchange,
                                self.routingKey];
    }
    return self;
}

@end

@interface AMQProtocolBasicGet ()
@property (nonnull, copy, nonatomic, readwrite) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *noAck;
@end

@implementation AMQProtocolBasicGet
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(70); }
+ (NSArray *)frames {
    return @[@[[AMQShort class],
               [AMQShortstr class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                    noAck:(nonnull AMQBit *)noAck {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.queue = queue;
        self.noAck = noAck;
        self.frameArguments = @[self.reserved1,
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
        self.frameArguments = @[self.reserved1,
                                self.queue,
                                self.noAck];
    }
    return self;
}

@end

@interface AMQProtocolBasicGetOk ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *redelivered;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readwrite) AMQLong *messageCount;
@end

@implementation AMQProtocolBasicGetOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(71); }
+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class],
               [AMQShortstr class],
               [AMQShortstr class],
               [AMQLong class]]];
}

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
        self.frameArguments = @[self.deliveryTag,
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
        self.frameArguments = @[self.deliveryTag,
                                self.redelivered,
                                self.exchange,
                                self.routingKey,
                                self.messageCount];
    }
    return self;
}

@end

@interface AMQProtocolBasicGetEmpty ()
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *reserved1;
@end

@implementation AMQProtocolBasicGetEmpty
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(72); }
+ (NSArray *)frames {
    return @[@[[AMQShortstr class]]];
}

- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.reserved1 = reserved1;
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.reserved1 = frames[0][0];
        self.frameArguments = @[self.reserved1];
    }
    return self;
}

@end

@interface AMQProtocolBasicAck ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *multiple;
@end

@implementation AMQProtocolBasicAck
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(80); }
+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                   multiple:(nonnull AMQBit *)multiple {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.multiple = multiple;
        self.frameArguments = @[self.deliveryTag,
                                self.multiple];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.deliveryTag = frames[0][0];
        self.multiple = frames[0][1];
        self.frameArguments = @[self.deliveryTag,
                                self.multiple];
    }
    return self;
}

@end

@interface AMQProtocolBasicReject ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *requeue;
@end

@implementation AMQProtocolBasicReject
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(90); }
+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    requeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.requeue = requeue;
        self.frameArguments = @[self.deliveryTag,
                                self.requeue];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.deliveryTag = frames[0][0];
        self.requeue = frames[0][1];
        self.frameArguments = @[self.deliveryTag,
                                self.requeue];
    }
    return self;
}

@end

@interface AMQProtocolBasicRecoverAsync ()
@property (nonnull, copy, nonatomic, readwrite) AMQBit *requeue;
@end

@implementation AMQProtocolBasicRecoverAsync
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(100); }
+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}

- (nonnull instancetype)initWithRequeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.requeue = requeue;
        self.frameArguments = @[self.requeue];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.requeue = frames[0][0];
        self.frameArguments = @[self.requeue];
    }
    return self;
}

@end

@interface AMQProtocolBasicRecover ()
@property (nonnull, copy, nonatomic, readwrite) AMQBit *requeue;
@end

@implementation AMQProtocolBasicRecover
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(110); }
+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}

- (nonnull instancetype)initWithRequeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.requeue = requeue;
        self.frameArguments = @[self.requeue];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.requeue = frames[0][0];
        self.frameArguments = @[self.requeue];
    }
    return self;
}

@end

@interface AMQProtocolBasicRecoverOk ()
@end

@implementation AMQProtocolBasicRecoverOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(111); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolBasicNack ()
@property (nonnull, copy, nonatomic, readwrite) AMQLonglong *deliveryTag;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *multiple;
@property (nonnull, copy, nonatomic, readwrite) AMQBit *requeue;
@end

@implementation AMQProtocolBasicNack
@synthesize frameArguments;

+ (NSNumber *)classID { return @(60); }
+ (NSNumber *)methodID { return @(120); }
+ (NSArray *)frames {
    return @[@[[AMQLonglong class],
               [AMQBit class],
               [AMQBit class]]];
}

- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                   multiple:(nonnull AMQBit *)multiple
                                    requeue:(nonnull AMQBit *)requeue {
    self = [super init];
    if (self) {
        self.deliveryTag = deliveryTag;
        self.multiple = multiple;
        self.requeue = requeue;
        self.frameArguments = @[self.deliveryTag,
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
        self.frameArguments = @[self.deliveryTag,
                                self.multiple,
                                self.requeue];
    }
    return self;
}

@end

@interface AMQProtocolTxSelect ()
@end

@implementation AMQProtocolTxSelect
@synthesize frameArguments;

+ (NSNumber *)classID { return @(90); }
+ (NSNumber *)methodID { return @(10); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolTxSelectOk ()
@end

@implementation AMQProtocolTxSelectOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(90); }
+ (NSNumber *)methodID { return @(11); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolTxCommit ()
@end

@implementation AMQProtocolTxCommit
@synthesize frameArguments;

+ (NSNumber *)classID { return @(90); }
+ (NSNumber *)methodID { return @(20); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolTxCommitOk ()
@end

@implementation AMQProtocolTxCommitOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(90); }
+ (NSNumber *)methodID { return @(21); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolTxRollback ()
@end

@implementation AMQProtocolTxRollback
@synthesize frameArguments;

+ (NSNumber *)classID { return @(90); }
+ (NSNumber *)methodID { return @(30); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolTxRollbackOk ()
@end

@implementation AMQProtocolTxRollbackOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(90); }
+ (NSNumber *)methodID { return @(31); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

@interface AMQProtocolConfirmSelect ()
@property (nonnull, copy, nonatomic, readwrite) AMQBit *nowait;
@end

@implementation AMQProtocolConfirmSelect
@synthesize frameArguments;

+ (NSNumber *)classID { return @(85); }
+ (NSNumber *)methodID { return @(10); }
+ (NSArray *)frames {
    return @[@[[AMQBit class]]];
}

- (nonnull instancetype)initWithNowait:(nonnull AMQBit *)nowait {
    self = [super init];
    if (self) {
        self.nowait = nowait;
        self.frameArguments = @[self.nowait];
    }
    return self;
}

- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.nowait = frames[0][0];
        self.frameArguments = @[self.nowait];
    }
    return self;
}

@end

@interface AMQProtocolConfirmSelectOk ()
@end

@implementation AMQProtocolConfirmSelectOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(85); }
+ (NSNumber *)methodID { return @(11); }
+ (NSArray *)frames {
    return @[@[]];
}


- (instancetype)initWithDecodedFrames:(NSArray *)frames {
    self = [super init];
    if (self) {
        self.frameArguments = @[];
    }
    return self;
}

@end

