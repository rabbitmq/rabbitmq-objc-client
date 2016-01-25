#import "AMQEncoder.h"

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

- (void)encodeObject:(NSDictionary *)objv forKey:(NSString *)key {
    [self.data appendData:[self encodeDictionary:objv]];
}

- (NSData *)encodeDictionary:(NSDictionary *)objv{
    if ([objv[@"type"] isEqualToString:@"long-string"]) {
        return [self encodeLongString:objv[@"value"]];
    } else if ([objv[@"type"] isEqualToString:@"short-string"]) {
        return [self encodeShortString:objv[@"value"]];
    } else if ([objv[@"type"] isEqualToString:@"boolean"]) {
        return [self encodeBoolean:objv[@"value"]];
    } else if ([objv[@"type"] isEqualToString:@"field-value-pair"]) {
        return [self encodeFieldValuePair:objv];
    } else if ([objv[@"type"] isEqualToString:@"field-table"]) {
        return [self encodeFieldTable:objv[@"value"]];
    } else {
        return [NSData data];
    }
}

- (NSData *)encodeFieldTable:(NSArray *)table {
    NSMutableData *tableContents = [NSMutableData new];
    
    for (NSDictionary *fieldPair in table) {
        [tableContents appendData:[self encodeFieldValuePair:fieldPair]];
    }
    
    NSMutableData *fieldTable = [[self encodeLongUInt:tableContents.length] mutableCopy];
    [fieldTable appendData:tableContents];
    
    return fieldTable;
}

- (NSData *)encodeFieldValuePair:(NSDictionary *)pair {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[self encodeShortString:pair[@"key"]]];
    
    NSDictionary *fieldValueTypes = @{@"boolean": @"t", @"field-table": @"F"};
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
    [encoded appendData:[self encodeLongUInt:value.length]];
    [encoded appendData:value];
    return encoded;
}

- (NSData *)encodeLongUInt:(NSUInteger)val {
    NSMutableData *encoded = [NSMutableData new];
    uint32_t longVal = CFSwapInt32HostToBig((uint32_t)val);
    [encoded appendBytes:&longVal length:sizeof(uint32_t)];
    return encoded;
}

@end
