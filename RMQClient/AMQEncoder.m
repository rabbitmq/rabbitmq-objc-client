#import "AMQEncoder.h"
#import "AMQProtocolValues.h"

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

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod {
    AMQMethodPayload *payload = [[AMQMethodPayload alloc] initWithClassID:[[AMQShort alloc] init:[amqMethod.class classID].integerValue]
                                                                 methodID:[[AMQShort alloc] init:[amqMethod.class methodID].integerValue]
                                                                arguments:amqMethod.frameArguments];
    NSMutableData *frame = [NSMutableData new];
    NSArray *unencodedFrame = @[[[AMQOctet alloc] init:1],
                                [[AMQShort alloc] init:0],
                                [[AMQLong alloc] init:payload.amqEncoded.length],
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
