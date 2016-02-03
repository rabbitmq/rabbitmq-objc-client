#import "AMQEncoder.h"
#import "AMQProtocol.h"

@interface AMQEncoder ()

@property (nonatomic, readwrite) NSMutableData *data;

@end

@implementation AMQEncoder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.data = [NSMutableData new];
    }
    return self;
}

- (NSData *)frameForClassID:(NSNumber *)classID
                   methodID:(NSNumber *)methodID {
    NSMutableData *frame = [NSMutableData new];
    NSMutableData *payload = [NSMutableData new];
    
    [payload appendData: [self encodeShortUInt:classID.integerValue]];
    [payload appendData: [self encodeShortUInt:methodID.integerValue]];
    [payload appendData:self.data];

    NSData *size = [[AMQLongUInt alloc] init:payload.length].amqEncoded;
    char type = 0x01;
    NSUInteger channel = 0;
    char frameEnd = 0xCE;
    
    [frame appendBytes:&type length:1];
    [frame appendData:[self encodeShortUInt:channel]];
    [frame appendData:size];
    [frame appendData:payload];
    [frame appendBytes:&frameEnd length:1];
    
    return frame;
}

- (void)encodeObject:(id)objv forKey:(NSString *)key {
    if ([objv isKindOfClass:[NSDictionary class]]) {
        [self.data appendData:[self encodeFieldTable:objv]];
    } else if ([objv isKindOfClass:[NSString class]]) {
        [self.data appendData:[[AMQLongString alloc] init:objv].amqEncoded];
    } else if ([objv isKindOfClass:[AMQShortString class]]) {
        [self.data appendData:[[AMQShortString alloc] init:[objv stringValue]].amqEncoded];
    } else {
        id <AMQEncoding> o = objv;
        [self.data appendData:o.amqEncoded];
    }
}

- (NSData *)encodeDictionary:(NSDictionary *)objv{
    if ([objv[@"type"] isEqualToString:@"long-string"]) {
        return [[AMQLongString alloc] init:objv[@"value"]].amqEncoded;
    } else if ([objv[@"type"] isEqualToString:@"short-string"]) {
        return [[AMQShortString alloc] init:objv[@"value"]].amqEncoded;
    } else if ([objv[@"type"] isEqualToString:@"field-table"]) {
        return [self encodeFieldTable:objv[@"value"]];
    } else {
        return [objv[@"value"] amqEncoded];
    }
}

- (NSData *)encodeFieldTable:(NSDictionary *)table {
    NSMutableData *tableContents = [NSMutableData new];
    NSArray *keys = [[table allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *key in keys) {
        id value = table[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            [tableContents appendData:[self encodeFieldValuePair:@{@"key": key,
                                                                   @"value": @{@"type": @"field-table",
                                                                               @"value": value}}]];
        } else if ([value isKindOfClass:[AMQBoolean class]]) {
            [tableContents appendData:[self encodeFieldValuePair:@{@"key": key,
                                                                   @"value": @{@"type": @"boolean",
                                                                               @"value": value}}]];
        } else if ([value isKindOfClass:[NSString class]]) {
            [tableContents appendData:[self encodeFieldValuePair:@{@"key": key,
                                                                   @"value": @{@"type": @"long-string",
                                                                               @"value": value}}]];
        } else {
            @throw @"haven't implemented yet!";
        }
    }
    
    NSMutableData *fieldTable = [[[AMQLongUInt alloc] init:tableContents.length].amqEncoded mutableCopy];
    [fieldTable appendData:tableContents];
    
    return fieldTable;
}

- (NSData *)encodeFieldValuePair:(NSDictionary *)pair {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQShortString alloc] init:pair[@"key"]].amqEncoded];
    
    NSDictionary *fieldValueTypes = @{@"boolean": @"t", @"field-table": @"F", @"long-string": @"S"};
    NSString *fieldValueType = fieldValueTypes[pair[@"value"][@"type"]];
    NSData *type = [fieldValueType dataUsingEncoding:NSASCIIStringEncoding];
    
    [encoded appendData:type];
    [encoded appendData:[self encodeDictionary:pair[@"value"]]];

    return encoded;
}

- (NSData *)encodeShortUInt:(NSUInteger)val {
    NSMutableData *encoded = [NSMutableData new];
    uint16_t shortVal = CFSwapInt16HostToBig((uint16_t)val);
    [encoded appendBytes:&shortVal length:sizeof(uint16_t)];
    return encoded;
}

@end
