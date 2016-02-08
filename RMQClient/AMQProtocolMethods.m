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
@synthesize classID;
@synthesize methodID;

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
        self.classID = @(10);
        self.methodID = @(10);
    }
    return self;
}

- (id<AMQOutgoing>)replyWithContext:(id<AMQReplyContext>)context {
    AMQTable *capabilities = [[AMQTable alloc] init:@{@"publisher_confirms": [[AMQBoolean alloc] init:YES],
                                                      @"consumer_cancel_notify": [[AMQBoolean alloc] init:YES],
                                                      @"exchange_exchange_bindings": [[AMQBoolean alloc] init:YES],
                                                      @"basic.nack": [[AMQBoolean alloc] init:YES],
                                                      @"connection.blocked": [[AMQBoolean alloc] init:YES],
                                                      @"authentication_failure_close": [[AMQBoolean alloc] init:YES]}];
    AMQTable *clientProperties = [[AMQTable alloc] init:
                                       @{@"capabilities" : capabilities,
                                         @"product"     : [[AMQLongstr alloc] init:@"RMQClient"],
                                         @"platform"    : [[AMQLongstr alloc] init:@"iOS"],
                                         @"version"     : [[AMQLongstr alloc] init:@"0.0.1"],
                                         @"information" : [[AMQLongstr alloc] init:@"https://github.com/camelpunch/RMQClient"]}];

    return [[AMQProtocolConnectionStartOk alloc] initWithClientProperties:clientProperties
                                                                mechanism:[[AMQShortstr alloc] init:@"PLAIN"]
                                                                 response:context.credentials
                                                                   locale:[[AMQShortstr alloc] init:@"en_GB"]];
}

@end

@interface AMQProtocolConnectionStartOk ()

@property (nonnull, copy, nonatomic, readwrite) AMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *response;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *locale;

@end

@implementation AMQProtocolConnectionStartOk
@synthesize classID;
@synthesize methodID;
@synthesize frameArguments;

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
        self.classID = @(10);
        self.methodID = @(11);
        self.frameArguments = @[self.clientProperties,
                                self.mechanism,
                                self.response,
                                self.locale];
    }
    return self;
}

- (NSData *)amqEncoded {
    return [[AMQEncoder new] encodeMethod:self];
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
@synthesize classID;
@synthesize methodID;
@synthesize frameArguments;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.channelMax = [[AMQShort alloc] initWithCoder:coder];
        self.frameMax = [[AMQLong alloc] initWithCoder:coder];
        self.heartbeat = [[AMQShort alloc] initWithCoder:coder];
    }
    return self;
}

- (id<AMQOutgoing>)replyWithContext:(id<AMQReplyContext>)context {
    return [[AMQProtocolConnectionTuneOk alloc] initWithChannelMax:self.channelMax
                                                          frameMax:self.frameMax
                                                         heartbeat:self.heartbeat];
}

@end

@interface AMQProtocolConnectionTuneOk ()
@property (nonatomic, copy, readwrite) AMQShort *channelMax;
@property (nonatomic, copy, readwrite) AMQLong *frameMax;
@property (nonatomic, copy, readwrite) AMQShort *heartbeat;
@end

@implementation AMQProtocolConnectionTuneOk
@synthesize classID;
@synthesize methodID;
@synthesize frameArguments;

- (instancetype)initWithChannelMax:(AMQShort *)channelMax
                          frameMax:(AMQLong *)frameMax
                         heartbeat:(AMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
        self.classID = @(10);
        self.methodID = @(31);
        self.frameArguments = @[self.channelMax, self.frameMax, self.heartbeat];
    }
    return self;
}

- (NSData *)amqEncoded {
    return [[AMQEncoder new] encodeMethod:self];
}

- (Class)expectedResponseClass {
    return nil;
}

- (id<AMQOutgoing>)nextRequest {
    return [[AMQProtocolConnectionOpen alloc] initWithVirtualHost:[[AMQShortstr alloc] init:@"/"]
                                                        reserved1:[[AMQShortstr alloc] init:@""]
                                                        reserved2:[[AMQBit alloc] init:0]];
}

@end

@interface AMQProtocolConnectionOpen ()
@property (nonatomic, copy, readwrite) AMQShortstr *vhost;
@property (nonatomic, copy, readwrite) AMQShortstr *capabilities;
@property (nonatomic, copy, readwrite) AMQBit *insist;
@end

@implementation AMQProtocolConnectionOpen
@synthesize classID;
@synthesize methodID;
@synthesize frameArguments;

- (instancetype)initWithVirtualHost:(AMQShortstr *)vhost
                          reserved1:(AMQShortstr *)capabilities
                          reserved2:(AMQBit *)insist {
    self = [super init];
    if (self) {
        self.vhost = vhost;
        self.capabilities = capabilities;
        self.insist = insist;
        self.classID = @(10);
        self.methodID = @(40);
        self.frameArguments = @[self.vhost, self.capabilities, self.insist];
    }
    return self;
}

- (NSData *)amqEncoded {
    return [[AMQEncoder new] encodeMethod:self];
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionOpenOk class];
}

@end

@interface AMQProtocolConnectionOpenOk ()
@property (nonatomic, copy, readwrite) AMQShortstr *knownHosts;
@end

@implementation AMQProtocolConnectionOpenOk
@synthesize classID;
@synthesize methodID;
@synthesize frameArguments;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.knownHosts = [coder decodeObjectForKey:@"10_41_known-hosts"];
    }
    return self;
}

- (id<AMQOutgoing>)replyWithContext:(id<AMQReplyContext>)context {
    return nil;
}

@end

@implementation AMQProtocolChannelOpen
@synthesize classID;
@synthesize methodID;
@synthesize frameArguments;

- (instancetype)initWithReserved1:(AMQShortstr *)reserved1 {
    self = [super init];
    if (self) {
        self.classID = @(20);
        self.methodID = @(10);
        self.frameArguments = @[];
    }
    return self;
}

- (NSData *)amqEncoded {
    return [[AMQEncoder new] encodeMethod:self];
}

- (Class)expectedResponseClass {
    return [AMQProtocolChannelOpenOk class];
}

@end

@interface AMQProtocolChannelOpenOk ()
@property (nonatomic, copy, readwrite) AMQLongstr *channelID;
@end

@implementation AMQProtocolChannelOpenOk
@synthesize classID;
@synthesize methodID;
@synthesize frameArguments;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.channelID = [coder decodeObjectForKey:@"20_11_channel-id"];
    }
    return self;
}

- (id<AMQOutgoing>)replyWithContext:(id<AMQReplyContext>)context {
    return nil;
}

@end