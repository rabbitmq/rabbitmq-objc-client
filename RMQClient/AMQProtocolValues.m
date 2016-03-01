#import "AMQProtocolValues.h"
#import "AMQProtocolBasicProperties.h"

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

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseOctet]];
}

- (NSData *)amqEncoded {
    char buffer = self.octet;
    return [NSData dataWithBytes:&buffer length:1];
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

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseBoolean]];
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

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseShortUInt]];
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

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseLongUInt]];
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
@property (nonatomic, readwrite) uint64_t integerValue;
@end

@implementation AMQLonglong

- (instancetype)init:(uint64_t)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseLongLongUInt]];
}

- (NSData *)amqEncoded {
    uint64_t longVal = CFSwapInt64HostToBig(self.integerValue);
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

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseShortString]];
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

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseLongString]];
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

- (instancetype)initWithParser:(AMQParser *)parser {
    return [self init:[parser parseFieldTable]];
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

@interface AMQTimestamp ()
@property (nonatomic, copy, readwrite) NSDate *date;
@end

@implementation AMQTimestamp

- (instancetype)init:(NSDate *)date {
    self = [super init];
    if (self) {
        self.date = date;
    }
    return self;
}

- (instancetype)initWithParser:(AMQParser *)parser {
    NSTimeInterval interval = [parser parseLongLongUInt];
    return [self init:[NSDate dateWithTimeIntervalSince1970:interval]];
}

- (NSData *)amqEncoded {
    NSTimeInterval interval = self.date.timeIntervalSince1970;
    AMQLonglong *numeric = [[AMQLonglong alloc] init:interval];
    return numeric.amqEncoded;
}

- (NSData *)amqFieldValueType {
    return [@"T" dataUsingEncoding:NSUTF8StringEncoding];
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

@interface AMQContentHeader ()
@property (nonatomic, copy, readwrite) NSNumber *classID;
@property (nonatomic, copy, readwrite) NSNumber *weight;
@property (nonatomic, copy, readwrite) NSNumber *bodySize;
@property (nonatomic, copy, readwrite) NSArray *properties;
@end

@implementation AMQContentHeader

- (instancetype)initWithClassID:(NSNumber *)classID
                       bodySize:(NSNumber *)bodySize
                     properties:(NSArray<AMQBasicValue> *)properties {
    self = [super init];
    if (self) {
        self.classID = classID;
        self.weight = @0;
        self.bodySize = bodySize;
        self.properties = properties;
    }
    return self;
}

- (instancetype)initWithParser:(AMQParser *)parser {
    NSNumber *classID = @([parser parseShortUInt]);
    [parser parseShortUInt]; // weight
    UInt64 bodySize = [parser parseLongLongUInt];
    UInt16 flags = [parser parseShortUInt];

    NSMutableArray *properties = [NSMutableArray new];
    int i = 0;
    for (Class propertyClass in [self propertyClassesWithFlags:flags]) {
        properties[i] = [[propertyClass alloc] initWithParser:parser];
        i++;
    }

    return [self initWithClassID:classID bodySize:@(bodySize) properties:properties];
}

- (NSNumber *)frameTypeID { return @2; }

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:self.weight.integerValue].amqEncoded];
    [encoded appendData:[[AMQLonglong alloc] init:self.bodySize.integerValue].amqEncoded];

    NSSortDescriptor *byFlagBit = [[NSSortDescriptor alloc] initWithKey:@"flagBit" ascending:NO];
    NSArray *sortedProperties = [self.properties sortedArrayUsingDescriptors:@[byFlagBit]];

    NSUInteger flags = 0;
    for (id <AMQBasicValue> property in sortedProperties) {
        flags |= property.flagBit;
    }
    [encoded appendData:[[AMQShort alloc] init:flags].amqEncoded];

    for (id <AMQBasicValue> property in sortedProperties) {
        [encoded appendData:property.amqEncoded];
    }

    return encoded;
}

- (NSArray *)propertyClassesWithFlags:(UInt16)flags {
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id <AMQBasicValue> _Nonnull propertyClass, NSDictionary<NSString *,id> * _Nullable bindings) {
        return (flags & [propertyClass flagBit]) != 0;
    }];
    return [[[AMQBasicProperties class] properties] filteredArrayUsingPredicate:pred];
}

@end

@implementation AMQContentHeaderNone

- (instancetype)initWithClassID:(NSNumber *)classID
                       bodySize:(NSNumber *)bodySize
                     properties:(NSArray<AMQBasicValue> *)properties {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithParser:(AMQParser *)parser {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSNumber *)frameTypeID {
    return nil;
}

- (NSData *)amqEncoded {
    return [NSData data];
}

@end

@interface AMQContentBody ()
@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) NSUInteger length;
@end

@implementation AMQContentBody

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
        self.length = data.length;
    }
    return self;
}

- (instancetype)initWithParser:(AMQParser *)parser payloadSize:(UInt32)payloadSize {
    return [self initWithData:[parser parseLength:payloadSize]];
}

- (NSNumber *)frameTypeID { return @3; }

- (NSData *)amqEncoded {
    return self.data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Body: %@", self.data];
}

@end