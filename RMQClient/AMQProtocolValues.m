#import "AMQProtocolValues.h"

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

@interface AMQBit ()
@property (nonatomic, readwrite) char bit;
@end

@implementation AMQBit

- (instancetype)init:(char)bit {
    self = [super init];
    if (self) {
        self.bit = bit;
    }
    return self;
}

- (NSData *)amqEncoded {
    char val = self.bit;
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
    NSMutableData *encoded = [NSMutableData new];
    uint64_t longVal = CFSwapInt64HostToBig((uint64_t)self.integerValue);
    [encoded appendBytes:&longVal length:sizeof(uint64_t)];
    return encoded;
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
    char zero = 0x00;
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:username];
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:password];

    NSString *s = [[NSString alloc] initWithData:encodedContent
                                        encoding:NSUTF8StringEncoding];
    return [[AMQLongstr alloc] init:s].amqEncoded;
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
