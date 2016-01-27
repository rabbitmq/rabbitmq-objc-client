#import "AMQEncoder.h"
#import "AMQCredentials.h"

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
    
    char type = 0x01;
    char *channel = malloc(2);
    channel[0] = channel[1] = 0x00;

    NSMutableData *payload = [NSMutableData new];
    
    [payload appendData: [self encodeShortUInt:classID.integerValue]];
    [payload appendData: [self encodeShortUInt:methodID.integerValue]];
    [payload appendData:self.data];

    NSData *size = [self encodeLongUInt:payload.length];
    
    char frameEnd = 0xCE;
    
    [frame appendBytes:&type length:1];
    [frame appendBytes:channel length:2];
    [frame appendData:size];
    [frame appendData:payload];
    [frame appendBytes:&frameEnd length:1];
    
    return frame;
}

- (void)encodeObject:(id)objv forKey:(NSString *)key {
    if ([key isEqualToString:@"10_11_response"]) {
        [self.data appendData:[self encodeCredentials:objv]];
    } else {
        [self.data appendData:[self encodeDictionary:objv]];
    }
}

- (NSData *)encodeCredentials:(AMQCredentials *)credentials {
    NSMutableData *encoded = [NSMutableData new];
    NSMutableData *encodedContent = [NSMutableData new];
    NSData *username = [credentials.username dataUsingEncoding:NSUTF8StringEncoding];
    NSData *password = [credentials.password dataUsingEncoding:NSUTF8StringEncoding];
    char zero = 0x00;
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:username];
    [encodedContent appendBytes:&zero length:1];
    [encodedContent appendData:password];
    
    [encoded appendData:[self encodeLongUInt:encodedContent.length]];
    [encoded appendData:encodedContent];
    
    return encoded;
}

- (NSData *)encodeDictionary:(NSDictionary *)objv{
    if ([objv[@"type"] isEqualToString:@"long-string"]) {
        return [self encodeLongString:objv[@"value"]];
    } else if ([objv[@"type"] isEqualToString:@"short-string"]) {
        return [self encodeShortString:objv[@"value"]];
    } else if ([objv[@"type"] isEqualToString:@"boolean"]) {
        return [self encodeBoolean:objv[@"value"]];
    } else if ([objv[@"type"] isEqualToString:@"field-table"]) {
        return [self encodeFieldTable:objv[@"value"]];
    } else {
        return [NSData data];
    }
}

- (NSData *)encodeFieldTable:(NSDictionary *)table {
    NSMutableData *tableContents = [NSMutableData new];
    NSArray *keys = [[table allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *key in keys) {
        NSDictionary *value = table[key];
        [tableContents appendData:[self encodeFieldValuePair:@{@"key": key,
                                                               @"value": @{@"type": value[@"type"],
                                                                           @"value": value[@"value"]}}]];
    }
    
    NSMutableData *fieldTable = [[self encodeLongUInt:tableContents.length] mutableCopy];
    [fieldTable appendData:tableContents];
    
    return fieldTable;
}

- (NSData *)encodeFieldValuePair:(NSDictionary *)pair {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[self encodeShortString:pair[@"key"]]];
    
    NSDictionary *fieldValueTypes = @{@"boolean": @"t", @"field-table": @"F", @"long-string": @"S"};
    NSString *fieldValueType = fieldValueTypes[pair[@"value"][@"type"]];
    NSData *type = [fieldValueType dataUsingEncoding:NSASCIIStringEncoding];
    
    [encoded appendData:type];
    [encoded appendData:[self encodeDictionary:pair[@"value"]]];

    return encoded;
}

- (NSData *)encodeBoolean:(NSNumber *)boolVal {
    BOOL val = boolVal.boolValue;
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendBytes:&val length:1];
    return encoded;
}

- (NSData *)encodeShortString:(NSString*)shortString {
    NSMutableData *encoded = [NSMutableData new];
    NSData *value = [shortString dataUsingEncoding:NSASCIIStringEncoding];
    char len = (char)value.length;
    [encoded appendBytes:&len length:1];
    [encoded appendData:value];
    return encoded;
}

- (NSData *)encodeLongString:(NSString*)longString {
    NSMutableData *encoded = [NSMutableData new];
    NSData *value = [longString dataUsingEncoding:NSASCIIStringEncoding];
    [encoded appendData: [self encodeLongUInt:value.length]];
    [encoded appendData:value];
    return encoded;
}

- (NSData *)encodeLongUInt:(NSUInteger)val {
    NSMutableData *encoded = [NSMutableData new];
    uint32_t longVal = CFSwapInt32HostToBig((uint32_t)val);
    [encoded appendBytes:&longVal length:sizeof(uint32_t)];
    return encoded;
}

- (NSData *)encodeShortUInt:(NSUInteger)val {
    NSMutableData *encoded = [NSMutableData new];
    uint16_t shortVal = CFSwapInt16HostToBig((uint16_t)val);
    [encoded appendBytes:&shortVal length:sizeof(uint16_t)];
    return encoded;
}

@end
