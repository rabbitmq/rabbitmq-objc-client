#import "RMQTable.h"

@interface RMQTable ()
@property (nonnull, nonatomic, copy, readwrite) NSDictionary *dictionaryValue;
@end

@implementation RMQTable

- (instancetype)init:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionaryValue = dictionary;
    }
    return self;
}

- (instancetype)init {
    return [self init:@{}];
}

- (instancetype)initWithParser:(RMQParser *)parser {
    return [self init:[parser parseFieldTable]];
}

- (NSData *)amqEncoded {
    NSMutableData *tableContents = [NSMutableData new];
    NSArray *keys = [[self.dictionaryValue allKeys] sortedArrayUsingSelector:@selector(compare:)];

    for (NSString *key in keys) {
        id value = self.dictionaryValue[key];
        RMQFieldValuePair *pair = [[RMQFieldValuePair alloc] initWithFieldName:key
                                                                    fieldValue:value];
        [tableContents appendData:pair.amqEncoded];
    }

    NSMutableData *fieldTable = [[[RMQLong alloc] init:tableContents.length].amqEncoded mutableCopy];
    [fieldTable appendData:tableContents];

    return fieldTable;
}

- (NSData *)amqFieldValueType {
    return [@"F" dataUsingEncoding:NSUTF8StringEncoding];
}

@end
