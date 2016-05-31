#import "RMQFrame.h"
#import "RMQMethodDecoder.h"
#import "RMQHeartbeat.h"

NSUInteger const RMQFrameMax = 131072;
NSInteger const RMQEmptyFrameSize = 8;

@interface RMQFrame ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<RMQPayload> payload;
@end

@implementation RMQFrame

- (instancetype)initWithChannelNumber:(NSNumber *)channelNumber
                              payload:(id<RMQPayload>)payload {
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.payload = payload;
    }
    return self;
}

- (instancetype)initWithParser:(RMQParser *)parser {
    char typeID             = [parser parseOctet];
    NSNumber *channelNumber = @([parser parseShortUInt]);
    UInt32 payloadSize      = [parser parseLongUInt];

    id <RMQPayload> payload;
    switch (typeID) {
        case RMQFrameTypeContentHeader:
            payload = [[RMQContentHeader alloc] initWithParser:parser];
            break;

        case RMQFrameTypeContentBody:
            payload = [[RMQContentBody alloc] initWithParser:parser payloadSize:payloadSize];
            break;

        case RMQFrameTypeHeartbeat:
            payload = [RMQHeartbeat new];
            break;

        default:
            payload = [[[RMQMethodDecoder alloc] initWithParser:parser] decode];
            break;
    }

    return [self initWithChannelNumber:channelNumber payload:payload];
}

- (NSData *)amqEncoded {
    NSMutableData *frameData = [NSMutableData new];
    NSArray *unencodedFrame = @[[[RMQOctet alloc] init:self.payload.frameTypeID.integerValue],
                                [[RMQShort alloc] init:self.channelNumber.integerValue],
                                [[RMQLong alloc] init:self.payload.amqEncoded.length],
                                self.payload,
                                [[RMQOctet alloc] init:0xCE]];
    for (id<RMQEncodable> part in unencodedFrame) {
        [frameData appendData:part.amqEncoded];
    }
    return frameData;
}

- (BOOL)isHeartbeat {
    return self.channelNumber.integerValue == 0 && [self.payload isKindOfClass:[RMQHeartbeat class]];
}

@end