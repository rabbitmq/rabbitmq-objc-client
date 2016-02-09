#import "AMQProtocolMethods.h"
#import "AMQEncoder.h"

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

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.versionMajor = [[AMQOctet alloc] initWithCoder:coder];
        self.versionMinor = [[AMQOctet alloc] initWithCoder:coder];
        self.serverProperties = [[AMQTable alloc] initWithCoder:coder];
        self.mechanisms = [[AMQLongstr alloc] initWithCoder:coder];
        self.locales = [[AMQLongstr alloc] initWithCoder:coder];
        self.frameArguments = @[self.versionMajor,
                                self.versionMinor,
                                self.serverProperties,
                                self.mechanisms,
                                self.locales,];
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

- (instancetype)initWithClientProperties:(AMQTable *)clientProperties
                               mechanism:(AMQShortstr *)mechanism
                                response:(AMQLongstr *)response
                                  locale:(AMQShortstr *)locale {
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

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionTune class];
}

@end

@interface AMQProtocolConnectionTune ()
@property (nonatomic, copy, readwrite) AMQShort *channelMax;
@property (nonatomic, copy, readwrite) AMQLong *frameMax;
@property (nonatomic, copy, readwrite) AMQShort *heartbeat;
@end

@implementation AMQProtocolConnectionTune
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(30); }

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.channelMax = [[AMQShort alloc] initWithCoder:coder];
        self.frameMax = [[AMQLong alloc] initWithCoder:coder];
        self.heartbeat = [[AMQShort alloc] initWithCoder:coder];
    }
    return self;
}

@end

@interface AMQProtocolConnectionTuneOk ()
@property (nonatomic, copy, readwrite) AMQShort *channelMax;
@property (nonatomic, copy, readwrite) AMQLong *frameMax;
@property (nonatomic, copy, readwrite) AMQShort *heartbeat;
@end

@implementation AMQProtocolConnectionTuneOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(31); }

- (instancetype)initWithChannelMax:(AMQShort *)channelMax
                          frameMax:(AMQLong *)frameMax
                         heartbeat:(AMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.frameArguments = @[self.channelMax, self.frameMax, self.heartbeat];
    }
    return self;
}

- (Class)expectedResponseClass {
    return nil;
}

@end

@interface AMQProtocolConnectionOpen ()
@property (nonatomic, copy, readwrite) AMQShortstr *vhost;
@property (nonatomic, copy, readwrite) AMQShortstr *capabilities;
@property (nonatomic, copy, readwrite) AMQBit *insist;
@end

@implementation AMQProtocolConnectionOpen
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(40); }

- (instancetype)initWithVirtualHost:(AMQShortstr *)vhost
                          reserved1:(AMQShortstr *)capabilities
                          reserved2:(AMQBit *)insist {
    self = [super init];
    if (self) {
        self.vhost = vhost;
        self.capabilities = capabilities;
        self.insist = insist;
        self.frameArguments = @[self.vhost, self.capabilities, self.insist];
    }
    return self;
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionOpenOk class];
}

@end

@interface AMQProtocolConnectionOpenOk ()
@property (nonatomic, copy, readwrite) AMQShortstr *knownHosts;
@end

@implementation AMQProtocolConnectionOpenOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(41); }

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.knownHosts = [[AMQShortstr alloc] initWithCoder:coder];
    }
    return self;
}

@end

@interface AMQProtocolConnectionClose ()
@property (nonatomic, copy, readwrite) AMQShort *replyCode;
@property (nonatomic, copy, readwrite) AMQShortstr *replyText;
@property (nonatomic, copy, readwrite) AMQShort *classId;
@property (nonatomic, copy, readwrite) AMQShort *methodId;
@end

@implementation AMQProtocolConnectionClose
@synthesize frameArguments;

+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(50); }

- (instancetype)initWithReplyCode:(AMQShort *)replyCode
                        replyText:(AMQShortstr *)replyText
                          classId:(AMQShort *)classId
                         methodId:(AMQShort *)methodId {
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

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionCloseOk class];
}

@end

@implementation AMQProtocolConnectionCloseOk
@synthesize frameArguments;
+ (NSNumber *)classID { return @(10); }
+ (NSNumber *)methodID { return @(51); }
- (Class)expectedResponseClass {
    return nil;
}
@end

@implementation AMQProtocolChannelOpen
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(10); }

- (instancetype)initWithReserved1:(AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.frameArguments = @[[[AMQShortstr alloc] init:@""]];
    }
    return self;
}

- (Class)expectedResponseClass {
    return [AMQProtocolChannelOpenOk class];
}

@end

@interface AMQProtocolChannelOpenOk ()
@property (nonatomic, copy, readwrite) AMQLongstr *channelID;
@end

@implementation AMQProtocolChannelOpenOk
@synthesize frameArguments;

+ (NSNumber *)classID { return @(20); }
+ (NSNumber *)methodID { return @(11); }

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.channelID = [[AMQLongstr alloc] initWithCoder:coder];
    }
    return self;
}

@end