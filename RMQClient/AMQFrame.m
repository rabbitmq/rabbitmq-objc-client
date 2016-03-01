#import "AMQFrame.h"
#import "AMQMethodDecoder.h"

@interface AMQFrame ()
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (nonatomic, readwrite) id<AMQPayload> payload;
@end

typedef NS_ENUM(char, AMQFrameType) {
    AMQFrameTypeMethod = 1,
    AMQFrameTypeContentHeader,
    AMQFrameTypeContentBody,
};

@implementation AMQFrame

- (instancetype)initWithChannelID:(NSNumber *)channelID
                          payload:(id<AMQPayload>)payload {
    self = [super init];
    if (self) {
        self.channelID = channelID;
        self.payload = payload;
    }
    return self;
}

- (instancetype)initWithParser:(AMQParser *)parser {
    char typeID         = [parser parseOctet];
    NSNumber *channelID = @([parser parseShortUInt]);
    UInt32 payloadSize  = [parser parseLongUInt];

    id <AMQPayload> payload;
    switch (typeID) {
        case AMQFrameTypeContentHeader:
            payload = [[AMQContentHeader alloc] initWithParser:parser];
            break;

        case AMQFrameTypeContentBody:
            payload = [[AMQContentBody alloc] initWithParser:parser payloadSize:payloadSize];
            break;

        default:
            payload = [[[AMQMethodDecoder alloc] initWithParser:parser] decode];
            break;
    }

    return [self initWithChannelID:channelID payload:payload];
}

- (NSData *)amqEncoded {
    NSMutableData *frameData = [NSMutableData new];
    NSArray *unencodedFrame = @[[[AMQOctet alloc] init:self.payload.frameTypeID.integerValue],
                                [[AMQShort alloc] init:self.channelID.integerValue],
                                [[AMQLong alloc] init:self.payload.amqEncoded.length],
                                self.payload,
                                [[AMQOctet alloc] init:0xCE]];
    for (id<AMQEncoding> part in unencodedFrame) {
        [frameData appendData:part.amqEncoded];
    }
    return frameData;
}

@end