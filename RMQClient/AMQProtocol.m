#import "AMQProtocol.h"

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

@interface AMQShortUInt ()
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation AMQShortUInt

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

@interface AMQLongUInt ()
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation AMQLongUInt

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

@interface AMQShortString ()
@property (nonnull, nonatomic, copy, readwrite) NSString *stringValue;
@end

@implementation AMQShortString

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

@interface AMQLongString ()
@property (nonnull, nonatomic, copy, readwrite) NSString *stringValue;
@end

@implementation AMQLongString

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
    [encoded appendData:[[AMQLongUInt alloc] init:value.length].amqEncoded];
    [encoded appendData:value];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"S" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface AMQFieldTable ()
@property (nonnull, nonatomic, copy, readwrite) NSDictionary *dictionary;
@end

@implementation AMQFieldTable

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

    NSMutableData *fieldTable = [[[AMQLongUInt alloc] init:tableContents.length].amqEncoded mutableCopy];
    [fieldTable appendData:tableContents];

    return fieldTable;
}

- (NSData *)amqFieldValueType {
    return [@"F" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface AMQFieldValuePair ()
@property (nonnull, nonatomic, copy) NSString *fieldName;
@property (nonnull, nonatomic, copy) id<AMQEncoding> fieldValue;
@end

@implementation AMQFieldValuePair

- (instancetype)initWithFieldName:(NSString *)fieldName fieldValue:(id<AMQEncoding>)fieldValue {
    self = [super init];
    if (self) {
        self.fieldName = fieldName;
        self.fieldValue = fieldValue;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShortString alloc] init:self.fieldName].amqEncoded];
    [encoded appendData:self.fieldValue.amqFieldValueType];
    [encoded appendData:self.fieldValue.amqEncoded];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return nil;
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

    [encoded appendData:[[AMQLongUInt alloc] init:encodedContent.length].amqEncoded];
    [encoded appendData:encodedContent];

    return encoded;
}

- (NSData *)amqFieldValueType {
    return nil;
}

@end

@interface AMQProtocolBasicConsumeOk ()
@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *consumerTag;
@end

@implementation AMQProtocolBasicConsumeOk

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"consume-ok";
        self.consumerTag = @"amq.ctag.foobar";
    }
    return self;
}

@end

@interface AMQProtocolConnectionStart ()
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMajor;
@property (nonnull, copy, nonatomic, readwrite) NSNumber *versionMinor;
@property (nonnull, copy, nonatomic, readwrite) NSDictionary<NSObject *, NSObject *> *serverProperties;
@property (nonnull, copy, nonatomic, readwrite) NSString *mechanisms;
@property (nonnull, copy, nonatomic, readwrite) NSString *locales;
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

- (instancetype)initWithVersionMajor:(NSNumber *)versionMajor
                        versionMinor:(NSNumber *)versionMinor
                    serverProperties:(NSDictionary<NSObject *,NSObject *> *)serverProperties
                          mechanisms:(NSString *)mechanisms
                             locales:(NSString *)locales {
    self = [super init];
    if (self) {
        self.serverProperties = serverProperties;
        self.versionMajor = versionMajor;
        self.versionMinor = versionMinor;
        self.mechanisms = mechanisms;
        self.locales = locales;
    }
    return self;
}

@end

@interface AMQProtocolConnectionStartOk ()

@property (nonnull, copy, nonatomic, readwrite) AMQFieldTable *clientProperties;
@property (nonnull, copy, nonatomic, readwrite) NSString *mechanism;
@property (nonnull, copy, nonatomic, readwrite) AMQCredentials *response;
@property (nonnull, copy, nonatomic, readwrite) NSString *locale;

@end

@implementation AMQProtocolConnectionStartOk

- (instancetype)initWithClientProperties:(AMQFieldTable *)clientProperties
                               mechanism:(NSString *)mechanism
                                response:(AMQCredentials *)response
                                  locale:(NSString *)locale {
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
    [coder encodeObject:[[AMQShortString alloc] init:self.mechanism]
                 forKey:@"10_11_mechanism"];
    [coder encodeObject:self.response
                 forKey:@"10_11_response"];
    [coder encodeObject:[[AMQShortString alloc] init:self.locale]
                 forKey:@"10_11_locale"];
}

@end