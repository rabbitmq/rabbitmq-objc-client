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
    
    [payload appendData:[[AMQShortUInt alloc] init:classID.integerValue].amqEncoded];
    [payload appendData:[[AMQShortUInt alloc] init:methodID.integerValue].amqEncoded];
    [payload appendData:self.data];

    NSData *size = [[AMQLongUInt alloc] init:payload.length].amqEncoded;
    char type = 0x01;
    NSUInteger channel = 0;
    char frameEnd = 0xCE;
    
    [frame appendBytes:&type length:1];
    [frame appendData:[[AMQShortUInt alloc] init:channel].amqEncoded];
    [frame appendData:size];
    [frame appendData:payload];
    [frame appendBytes:&frameEnd length:1];
    
    return frame;
}

- (void)encodeObject:(id<AMQEncoding>)objv forKey:(NSString *)key {
    [self.data appendData:objv.amqEncoded];
}

@end
