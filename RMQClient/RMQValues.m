#import "RMQValues.h"
#import "RMQBasicProperties.h"

@implementation RMQValue
@end

@interface RMQOctet ()
@property (nonatomic, readwrite) char octet;
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation RMQOctet

- (instancetype)init:(char)octet {
    self = [super init];
    if (self) {
        self.octet = octet;
        self.integerValue = (NSUInteger)octet;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
    return [self init:[parser parseOctet]];
}

- (NSData *)amqEncoded {
    char buffer = self.octet;
    return [NSData dataWithBytes:&buffer length:1];
}

@end

@interface RMQSignedByte ()
@property (nonatomic, readwrite) signed char byte;
@property (nonatomic, readwrite) NSInteger integerValue;
@end

@implementation RMQSignedByte

- (instancetype)init:(signed char)byte {
    self = [super init];
    if (self) {
        self.byte = byte;
        self.integerValue = (NSInteger)byte;
    }
    return self;
}

- (NSData *)amqEncoded {
    signed char buffer = self.byte;
    return [NSData dataWithBytes:&buffer length:1];
}

- (NSData *)amqFieldValueType {
    return [@"b" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQBoolean ()
@property (nonatomic, readwrite) BOOL boolValue;
@end

@implementation RMQBoolean

- (instancetype)init:(BOOL)boolean {
    self = [super init];
    if (self) {
        self.boolValue = boolean;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
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

@interface RMQSignedShort ()
@property (nonatomic, readwrite) NSInteger integerValue;
@end

@implementation RMQSignedShort

- (instancetype)init:(NSInteger)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    int16_t shortVal = CFSwapInt16HostToBig((int16_t)self.integerValue);
    return [NSData dataWithBytes:&shortVal length:sizeof(int16_t)];
}

- (NSData *)amqFieldValueType {
    return [@"s" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQShort ()
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation RMQShort

- (instancetype)init:(NSUInteger)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
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

@implementation RMQShortShort
- (NSData *)amqFieldValueType {
    return [@"b" dataUsingEncoding:NSUTF8StringEncoding];
}
@end

@interface RMQSignedLong ()
@property (nonatomic, readwrite) NSInteger integerValue;
@end

@implementation RMQSignedLong

- (instancetype)init:(NSInteger)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    int32_t longVal = CFSwapInt32HostToBig((int32_t)self.integerValue);
    return [NSData dataWithBytes:&longVal length:sizeof(int32_t)];
}

- (NSData *)amqFieldValueType {
    return [@"I" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQLong ()
@property (nonatomic, readwrite) NSUInteger integerValue;
@end

@implementation RMQLong

- (instancetype)init:(NSUInteger)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
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

@interface RMQSignedLonglong ()
@property (nonatomic, readwrite) int64_t integerValue;
@end

@implementation RMQSignedLonglong

- (instancetype)init:(int64_t)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    int64_t longVal = CFSwapInt64HostToBig(self.integerValue);
    return [NSData dataWithBytes:&longVal length:sizeof(int64_t)];
}

- (NSData *)amqFieldValueType {
    return [@"l" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQLonglong ()
@property (nonatomic, readwrite) uint64_t integerValue;
@end

@implementation RMQLonglong

- (instancetype)init:(uint64_t)val {
    self = [super init];
    if (self) {
        self.integerValue = val;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
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

@interface RMQFloat ()
@property (nonatomic, readwrite) float floatValue;
@end

@implementation RMQFloat

- (instancetype)init:(float)val {
    self = [super init];
    if (self) {
        self.floatValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    CFSwappedFloat32 floatVal = CFConvertFloatHostToSwapped(self.floatValue);
    return [NSData dataWithBytes:&floatVal length:sizeof(CFSwappedFloat32)];
}

- (NSData *)amqFieldValueType {
    return [@"f" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQDouble ()
@property (nonatomic, readwrite) double doubleValue;
@end

@implementation RMQDouble

- (instancetype)init:(double)val {
    self = [super init];
    if (self) {
        self.doubleValue = val;
    }
    return self;
}

- (NSData *)amqEncoded {
    CFSwappedFloat64 doubleVal = CFConvertDoubleHostToSwapped(self.doubleValue);
    return [NSData dataWithBytes:&doubleVal length:sizeof(CFSwappedFloat64)];
}

- (NSData *)amqFieldValueType {
    return [@"d" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation RMQDecimal

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQOctet alloc] init:0].amqEncoded];
    [encoded appendData:[[RMQLong alloc] init:0].amqEncoded];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"D" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQShortstr ()
@property (nonnull, nonatomic, copy, readwrite) NSString *stringValue;
@end

@implementation RMQShortstr

- (instancetype)init:(NSString *)string {
    self = [super init];
    if (self) {
        self.stringValue = string;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
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

@end

@interface RMQLongstr ()
@property (nonnull, nonatomic, copy, readwrite) NSString *stringValue;
@end

@implementation RMQLongstr

- (instancetype)init:(NSString *)string {
    self = [super init];
    if (self) {
        self.stringValue = string;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
    return [self init:[parser parseLongString]];
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    NSData *value = [self.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    [encoded appendData:[[RMQLong alloc] init:value.length].amqEncoded];
    [encoded appendData:value];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"S" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQArray ()
@property (nonatomic, readwrite) NSArray *vals;
@end

@implementation RMQArray

- (instancetype)init:(NSArray<RMQValue<RMQFieldValue> *> *)vals {
    self = [super init];
    if (self) {
        self.vals = vals;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *fieldValues = [NSMutableData new];
    for (RMQValue<RMQFieldValue> *val in self.vals) {
        [fieldValues appendData:val.amqFieldValueType];
        [fieldValues appendData:val.amqEncoded];
    }
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQLong alloc] init:4 + fieldValues.length].amqEncoded];
    [encoded appendData:fieldValues];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"A" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQTimestamp ()
@property (nonatomic, copy, readwrite) NSDate *date;
@end

@implementation RMQTimestamp

- (instancetype)init:(NSDate *)date {
    self = [super init];
    if (self) {
        self.date = date;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
    return [self init:[parser parseTimestamp]];
}

- (NSData *)amqEncoded {
    NSTimeInterval interval = self.date.timeIntervalSince1970;
    RMQLonglong *numeric = [[RMQLonglong alloc] init:interval];
    return numeric.amqEncoded;
}

- (NSData *)amqFieldValueType {
    return [@"T" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation RMQVoid

- (NSData *)amqEncoded {
    return [NSData data];
}

- (NSData *)amqFieldValueType {
    return [@"V" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQByteArray ()
@property (nonatomic, readwrite) NSData *data;
@end

@implementation RMQByteArray

- (instancetype)init:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQLong alloc] init:self.data.length].amqEncoded];
    [encoded appendData:self.data];
    return encoded;
}

- (NSData *)amqFieldValueType {
    return [@"x" dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@interface RMQFieldValuePair ()
@property (nonnull, nonatomic, copy) NSString *fieldName;
@property (nonnull, nonatomic, copy) id<RMQEncodable,RMQFieldValue> fieldValue;
@end

@implementation RMQFieldValuePair

- (instancetype)initWithFieldName:(NSString *)fieldName
                       fieldValue:(id<RMQEncodable,RMQFieldValue>)fieldValue {
    self = [super init];
    if (self) {
        self.fieldName = fieldName;
        self.fieldValue = fieldValue;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQShortstr alloc] init:self.fieldName].amqEncoded];
    [encoded appendData:self.fieldValue.amqFieldValueType];
    [encoded appendData:self.fieldValue.amqEncoded];
    return encoded;
}

@end

@interface RMQCredentials ()

@property (nonatomic, readwrite) NSString *username;
@property (nonatomic, readwrite) NSString *password;

@end

@implementation RMQCredentials

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
    return [[RMQLongstr alloc] init:s].amqEncoded;
}

@end

@interface RMQContentHeader ()
@property (nonatomic, copy, readwrite) NSNumber *classID;
@property (nonatomic, copy, readwrite) NSNumber *weight;
@property (nonatomic, copy, readwrite) NSNumber *bodySize;
@property (nonatomic, copy, readwrite) NSArray *properties;
@end

@implementation RMQContentHeader

- (instancetype)initWithClassID:(NSNumber *)classID
                       bodySize:(NSNumber *)bodySize
                     properties:(NSArray<RMQBasicValue> *)properties {
    self = [super init];
    if (self) {
        self.classID = classID;
        self.weight = @0;
        self.bodySize = bodySize;
        self.properties = properties;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
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
    [encoded appendData:[[RMQShort alloc] init:self.classID.integerValue].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:self.weight.integerValue].amqEncoded];
    [encoded appendData:[[RMQLonglong alloc] init:self.bodySize.integerValue].amqEncoded];

    NSSortDescriptor *byFlagBit = [[NSSortDescriptor alloc] initWithKey:@"flagBit" ascending:NO];
    NSArray *sortedProperties = [self.properties sortedArrayUsingDescriptors:@[byFlagBit]];

    NSUInteger flags = 0;
    for (id <RMQBasicValue> property in sortedProperties) {
        flags |= property.flagBit;
    }
    [encoded appendData:[[RMQShort alloc] init:flags].amqEncoded];

    for (id <RMQBasicValue> property in sortedProperties) {
        [encoded appendData:property.amqEncoded];
    }

    return encoded;
}

- (NSArray *)propertyClassesWithFlags:(UInt16)flags {
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id <RMQBasicValue> _Nonnull propertyClass, NSDictionary<NSString *,id> * _Nullable bindings) {
        return (flags & [propertyClass flagBit]) != 0;
    }];
    return [[[RMQBasicProperties class] properties] filteredArrayUsingPredicate:pred];
}

@end

@implementation RMQContentHeaderNone

- (instancetype)initWithClassID:(NSNumber *)classID
                       bodySize:(NSNumber *)bodySize
                     properties:(NSArray<RMQBasicValue> *)properties {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithParser:(RMQParser *)parser {
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

@interface RMQContentBody ()
@property (nonatomic, readwrite) NSData *data;
@property (nonatomic, readwrite) NSUInteger length;
@end

@implementation RMQContentBody

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
        self.length = data.length;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser payloadSize:(UInt32)payloadSize {
    return [self initWithData:[parser parseLength:payloadSize]];
}

- (NSNumber *)frameTypeID { return @3; }

- (NSData *)amqEncoded {
    return self.data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Body: %@", [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
}

@end