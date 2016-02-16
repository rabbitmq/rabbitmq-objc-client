#import "AMQProtocolValues.h"

@interface AMQOctet ()
@property (nonatomic, readwrite) char octet;
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation AMQOctet

- (instancetype)init:(char)octet {
    self = [super init];
    if (self) {
        self.octet = octet;
        self.integerValue = (NSUInteger)octet;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    return [coder decodeObjectForKey:@"octet"];
}

- (NSData *)amqEncoded {
    char buffer = self.octet;
    return [NSData dataWithBytes:&buffer length:1];
}

@end

@implementation AMQBit
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
    return [NSData dataWithBytes:&val length:1];
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

- (id)initWithCoder:(NSCoder *)coder {
    return [coder decodeObjectForKey:@"short"];
}

- (NSData *)amqEncoded {
    uint16_t shortVal = CFSwapInt16HostToBig((uint16_t)self.integerValue);
    return [NSData dataWithBytes:&shortVal length:sizeof(uint16_t)];
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

- (id)initWithCoder:(NSCoder *)coder {
    return [coder decodeObjectForKey:@"long"];
}

- (NSData *)amqEncoded {
    uint32_t longVal = CFSwapInt32HostToBig((uint32_t)self.integerValue);
    return [NSData dataWithBytes:&longVal length:sizeof(uint32_t)];
}

- (NSData *)amqFieldValueType {
    return [@"i" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface AMQLonglong ()
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation AMQLonglong

- (instancetype)init:(NSUInteger)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    uint64_t longVal = CFSwapInt64HostToBig((uint64_t)self.integerValue);
    return [NSData dataWithBytes:&longVal length:sizeof(uint64_t)];
}

- (NSData *)amqFieldValueType {
    return [@"l" dataUsingEncoding:NSUTF8StringEncoding];
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

- (id)initWithCoder:(NSCoder *)coder {
    return [coder decodeObjectForKey:@"shortstr"];
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    NSData *value = [self.stringValue dataUsingEncoding:NSUTF8StringEncoding];
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

- (id)initWithCoder:(NSCoder *)coder {
    return [coder decodeObjectForKey:@"longstr"];
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    NSData *value = [self.stringValue dataUsingEncoding:NSUTF8StringEncoding];
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

- (id)initWithCoder:(NSCoder *)coder {
    return [coder decodeObjectForKey:@"field-table"];
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
    NSMutableData *encodedContent = [NSMutableData new];
    NSData *username = [self.username dataUsingEncoding:NSUTF8StringEncoding];
    NSData *password = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    char zero = 0;
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:username];
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:password];

    NSString *s = [[NSString alloc] initWithData:encodedContent
                                        encoding:NSUTF8StringEncoding];
    return [[AMQLongstr alloc] init:s].amqEncoded;
}

@end

@interface AMQFrameset ()
@property (nonatomic, copy, readwrite) NSNumber *typeID;
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (nonatomic, copy, readwrite) id<AMQMethod> method;
@property (nonatomic, readwrite) NSArray *frames;
@end

@implementation AMQFrameset

- (instancetype)initWithTypeID:(NSNumber *)typeID
                     channelID:(NSNumber *)channelID
                        method:(id<AMQMethod>)method {
    self = [super init];
    if (self) {
        self.typeID = typeID;
        self.channelID = channelID;
        self.method = method;
        self.frames = @[];
    }
    return self;
}

@end

@interface AMQMethodFrame ()
@property (nonatomic, copy, readwrite) NSNumber *typeID;
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (nonatomic, copy, readwrite) id<AMQMethod> method;
@end

@implementation AMQMethodFrame

- (instancetype)initWithTypeID:(NSNumber *)typeID
                     channelID:(NSNumber *)channelID
                        method:(id<AMQMethod>)method {
    self = [super init];
    if (self) {
        self.typeID = typeID;
        self.channelID = channelID;
        self.method = method;
    }
    return self;
}

- (NSData *)amqEncoded {
    AMQMethodPayload *payload = [[AMQMethodPayload alloc] initWithClassID:[self.method.class classID]
                                                                 methodID:[self.method.class methodID]
                                                                arguments:self.method.frameArguments];
    NSMutableData *frameData = [NSMutableData new];
    NSArray *unencodedFrame = @[[[AMQOctet alloc] init:self.typeID.integerValue],
                                [[AMQShort alloc] init:self.channelID.integerValue],
                                [[AMQLong alloc] init:payload.amqEncoded.length],
                                payload,
                                [[AMQOctet alloc] init:0xCE]];
    for (id<AMQEncoding> part in unencodedFrame) {
        [frameData appendData:part.amqEncoded];
    }
    return frameData;
}

@end

@interface AMQMethodPayload ()
@property (nonatomic, copy, readwrite) NSNumber *classID;
@property (nonatomic, copy, readwrite) NSNumber *methodID;
@property (nonatomic, copy, readwrite) NSArray *arguments;
@end

@implementation AMQMethodPayload

- (instancetype)initWithClassID:(NSNumber *)classID
                       methodID:(NSNumber *)methodID
                      arguments:(NSArray *)arguments {
    self = [super init];
    if (self) {
        self.classID = classID;
        self.methodID = methodID;
        self.arguments = arguments;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.methodID.integerValue].amqEncoded];
    for (id<AMQEncoding>arg in self.arguments) {
        [encoded appendData:arg.amqEncoded];
    }
    return encoded;
}

@end