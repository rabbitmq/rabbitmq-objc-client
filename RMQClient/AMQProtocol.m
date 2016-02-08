#import "AMQProtocol.h"
#import "AMQEncoder.h"

@interface AMQOctet ()
@property (nonatomic, readwrite) char octet;
@end

@implementation AMQOctet

- (instancetype)init:(char)octet {
    self = [super init];
    if (self) {
        self.octet = octet;
    }
    return self;
}

- (NSData *)amqEncoded {
    char val = self.octet;
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendBytes:&val length:1];
    return encoded;
}

@end

@interface AMQBoolean ()
@property (nonatomic, readwrite) BOOL boolValue;
@end

@implementation AMQBoolean
- (instancetype)init:(BOOL)boolean {
    self = [super init];
    if (self) {
        self.boolValue = boolean;
    }
    return self;
}
- (NSData *)amqEncoded {
    BOOL val = self.boolValue;
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendBytes:&val length:1];
    return encoded;
}
- (NSData *)amqFieldValueType {
    return [@"t" dataUsingEncoding:NSUTF8StringEncoding];
}
@end

@interface AMQShort ()
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation AMQShort

- (instancetype)init:(NSUInteger)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    uint16_t shortVal = CFSwapInt16HostToBig((uint16_t)self.integerValue);
    [encoded appendBytes:&shortVal length:sizeof(uint16_t)];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"u" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface AMQLong ()
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation AMQLong

- (instancetype)init:(NSUInteger)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    uint32_t longVal = CFSwapInt32HostToBig((uint32_t)self.integerValue);
    [encoded appendBytes:&longVal length:sizeof(uint32_t)];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"i" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface AMQShortstr ()
@property (nonnull, nonatomic, copy, readwrite) NSString *stringValue;
@end

@implementation AMQShortstr

- (instancetype)init:(NSString *)string {
    self = [super init];
    if (self) {
        self.stringValue = string;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    NSData *value = [self.stringValue dataUsingEncoding:NSASCIIStringEncoding];
    char len = (char)value.length;
    [encoded appendBytes:&len length:1];
    [encoded appendData:value];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"s" dataUsingEncoding:NSUTF8StringEncoding];
}
@end

@interface AMQLongstr ()
@property (nonnull, nonatomic, copy, readwrite) NSString *stringValue;
@end

@implementation AMQLongstr

- (instancetype)init:(NSString *)string {
    self = [super init];
    if (self) {
        self.stringValue = string;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    NSData *value = [self.stringValue dataUsingEncoding:NSASCIIStringEncoding];
    [encoded appendData:[[AMQLong alloc] init:value.length].amqEncoded];
    [encoded appendData:value];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"S" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface AMQTable ()
@property (nonnull, nonatomic, copy, readwrite) NSDictionary *dictionary;
@end

@implementation AMQTable

- (instancetype)init:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *tableContents = [NSMutableData new];
    NSArray *keys = [[self.dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];

    for (NSString *key in keys) {
        id value = self.dictionary[key];
        AMQFieldValuePair *pair = [[AMQFieldValuePair alloc] initWithFieldName:key
                                                                    fieldValue:value];
        [tableContents appendData:pair.amqEncoded];
    }

    NSMutableData *fieldTable = [[[AMQLong alloc] init:tableContents.length].amqEncoded mutableCopy];
    [fieldTable appendData:tableContents];

    return fieldTable;
}

- (NSData *)amqFieldValueType {
    return [@"F" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface AMQFieldValuePair ()
@property (nonnull, nonatomic, copy) NSString *fieldName;
@property (nonnull, nonatomic, copy) id<AMQEncoding,AMQFieldValue> fieldValue;
@end

@implementation AMQFieldValuePair

- (instancetype)initWithFieldName:(NSString *)fieldName
                       fieldValue:(id<AMQEncoding,AMQFieldValue>)fieldValue {
    self = [super init];
    if (self) {
        self.fieldName = fieldName;
        self.fieldValue = fieldValue;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShortstr alloc] init:self.fieldName].amqEncoded];
    [encoded appendData:self.fieldValue.amqFieldValueType];
    [encoded appendData:self.fieldValue.amqEncoded];
    return encoded;
}

@end

@interface AMQCredentials ()

@property (nonatomic, readwrite) NSString *username;
@property (nonatomic, readwrite) NSString *password;

@end

@implementation AMQCredentials

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    NSMutableData *encodedContent = [NSMutableData new];
    NSData *username = [self.username dataUsingEncoding:NSUTF8StringEncoding];
    NSData *password = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    char zero = 0x00;
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:username];
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:password];

    [encoded appendData:[[AMQLong alloc] init:encodedContent.length].amqEncoded];
    [encoded appendData:encodedContent];

    return encoded;
}

@end

@interface AMQMethodPayload ()
@property (nonatomic, copy, readwrite) AMQShort *classID;
@property (nonatomic, copy, readwrite) AMQShort *methodID;
@property (nonatomic, copy, readwrite) NSData *data;
@end

@implementation AMQMethodPayload

- (instancetype)initWithClassID:(AMQShort *)classID
                       methodID:(AMQShort *)methodID
                           data:(NSData *)data {
    self = [super init];
    if (self) {
        self.classID = classID;
        self.methodID = methodID;
        self.data = data;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];

    [encoded appendData:self.classID.amqEncoded];
    [encoded appendData:self.methodID.amqEncoded];
    [encoded appendData:self.data];

    return encoded;
}

@end

@implementation AMQProtocolHeader

- (NSData *)amqEncoded {
    char *buffer = malloc(8);
    memcpy(buffer, "AMQP", strlen("AMQP"));
    buffer[4] = 0x00;
    buffer[5] = 0x00;
    buffer[6] = 0x09;
    buffer[7] = 0x01;
    return [NSData dataWithBytesNoCopy:buffer length:8];
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionStart class];
}

@end

@interface AMQProtocolConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) AMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) AMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) AMQLongstr *locales;
@end

@implementation AMQProtocolConnectionStart

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.versionMajor = [coder decodeObjectForKey:@"10_10_version-major"];
        self.versionMinor = [coder decodeObjectForKey:@"10_10_version-minor"];
        self.serverProperties = [coder decodeObjectForKey:@"10_10_server-properties"];
        self.mechanisms = [coder decodeObjectForKey:@"10_10_mechanisms"];
        self.locales = [coder decodeObjectForKey:@"10_10_locales"];
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
@property (nonnull, copy, nonatomic, readwrite) AMQCredentials *response;
@property (nonnull, copy, nonatomic, readwrite) AMQShortstr *locale;

@end

@implementation AMQProtocolConnectionStartOk

- (instancetype)initWithClientProperties:(AMQTable *)clientProperties
                               mechanism:(AMQShortstr *)mechanism
                                response:(AMQCredentials *)response
                                  locale:(AMQShortstr *)locale {
    self = [super init];
    if (self) {
        self.clientProperties = clientProperties;
        self.mechanism = mechanism;
        self.response = response;
        self.locale = locale;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.clientProperties
                 forKey:@"10_11_client-properties"];
    [coder encodeObject:self.mechanism
                 forKey:@"10_11_mechanism"];
    [coder encodeObject:self.response
                 forKey:@"10_11_response"];
    [coder encodeObject:self.locale
                 forKey:@"10_11_locale"];
}

- (NSData *)amqEncoded {
    AMQEncoder *encoder = [AMQEncoder new];
    [self encodeWithCoder:encoder];
    return [encoder frameForClassID:@(10) methodID:@(11)];
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

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.channelMax = [coder decodeObjectForKey:@"10_30_channel-max"];
        self.frameMax = [coder decodeObjectForKey:@"10_30_frame-max"];
        self.heartbeat = [coder decodeObjectForKey:@"10_30_heartbeat"];
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

- (instancetype)initWithChannelMax:(AMQShort *)channelMax
                          frameMax:(AMQLong *)frameMax
                         heartbeat:(AMQShort *)heartbeat {
    self = [super init];
    if (self) {
        self.channelMax = channelMax;
        self.frameMax = frameMax;
        self.heartbeat = heartbeat;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.channelMax
                 forKey:@"10_31_channel-max"];
    [coder encodeObject:self.frameMax
                 forKey:@"10_31_frame-max"];
    [coder encodeObject:self.heartbeat
                 forKey:@"10_31_heartbeat"];
}

- (NSData *)amqEncoded {
    AMQEncoder *encoder = [AMQEncoder new];
    [self encodeWithCoder:encoder];
    return [encoder frameForClassID:@(10) methodID:@(31)];
}

- (Class)expectedResponseClass {
    return nil;
}

- (id<AMQOutgoing>)nextRequest {
    return [[AMQProtocolConnectionOpen alloc] initWithVirtualHost:[[AMQShortstr alloc] init:@"/"]
                                                     capabilities:[[AMQShortstr alloc] init:@""]
                                                           insist:[[AMQBoolean alloc] init:false]];
}

@end

@interface AMQProtocolConnectionOpen ()
@property (nonatomic, copy, readwrite) AMQShortstr *vhost;
@property (nonatomic, copy, readwrite) AMQShortstr *capabilities;
@property (nonatomic, copy, readwrite) AMQBoolean *insist;
@end

@implementation AMQProtocolConnectionOpen

- (instancetype)initWithVirtualHost:(AMQShortstr *)vhost
                       capabilities:(AMQShortstr *)capabilities
                             insist:(AMQBoolean *)insist {
    self = [super init];
    if (self) {
        self.vhost = vhost;
        self.capabilities = capabilities;
        self.insist = insist;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.vhost
                 forKey:@"10_40_virtual-host"];
    [coder encodeObject:self.capabilities
                 forKey:@"10_40_capabilities"];
    [coder encodeObject:self.insist
                 forKey:@"10_40_insist"];
}

- (NSData *)amqEncoded {
    AMQEncoder *encoder = [AMQEncoder new];
    [self encodeWithCoder:encoder];
    return [encoder frameForClassID:@(10) methodID:@(40)];
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionOpenOk class];
}

@end

@interface AMQProtocolConnectionOpenOk ()
@property (nonatomic, copy, readwrite) AMQShortstr *knownHosts;
@end

@implementation AMQProtocolConnectionOpenOk

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

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[[AMQShortstr alloc] init:@""] forKey:@"20_10_out-of-band"];
}

- (NSData *)amqEncoded {
    AMQEncoder *encoder = [AMQEncoder new];
    [self encodeWithCoder:encoder];
    return [encoder frameForClassID:@(20) methodID:@(10)];
}

- (Class)expectedResponseClass {
    return [AMQProtocolChannelOpenOk class];
}

@end

@interface AMQProtocolChannelOpenOk ()
@property (nonatomic, copy, readwrite) AMQLongstr *channelID;
@end

@implementation AMQProtocolChannelOpenOk

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