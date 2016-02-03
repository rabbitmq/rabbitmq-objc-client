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
    AMQMethodPayload *payload = [[AMQMethodPayload alloc] initWithClassID:[[AMQShortUInt alloc] init:classID.integerValue]
                                                                 methodID:[[AMQShortUInt alloc] init:methodID.integerValue]
                                                                     data:self.data];
    NSMutableData *frame = [NSMutableData new];
    NSArray *unencodedFrame = @[[[AMQOctet alloc] init:1],
                                [[AMQShortUInt alloc] init:0],
                                [[AMQLongUInt alloc] init:payload.amqEncoded.length],
                                payload,
                                [[AMQOctet alloc] init:0xCE]];
    for (id<AMQEncoding> part in unencodedFrame) {
        [frame appendData:part.amqEncoded];
    }
    return frame;
}

- (void)encodeObject:(id<AMQEncoding>)objv forKey:(NSString *)key {
    [self.data appendData:objv.amqEncoded];
}

@end
