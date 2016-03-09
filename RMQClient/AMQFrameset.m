#import "AMQFrameset.h"
#import "AMQFrame.h"

@interface AMQFrameset ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<AMQMethod> method;
@property (nonatomic, readwrite) AMQContentHeader *contentHeader;
@property (nonatomic, readwrite) NSArray *contentBodies;
@end

@implementation AMQFrameset

- (instancetype)initWithChannelNumber:(NSNumber *)channelNumber
                               method:(id<AMQMethod>)method
                        contentHeader:(AMQContentHeader *)contentHeader
                        contentBodies:(NSArray *)contentBodies {
    self = [super init];
    if (self) {
        self.channelNumber = channelNumber;
        self.method = method;
        self.contentHeader = contentHeader;
        self.contentBodies = contentBodies;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQFrame alloc] initWithChannelNumber:self.channelNumber payload:self.method].amqEncoded];
    NSData *contentHeaderEncoded = self.contentHeader.amqEncoded;
    if (contentHeaderEncoded.length) {
        [encoded appendData:[[AMQFrame alloc] initWithChannelNumber:self.channelNumber payload:self.contentHeader].amqEncoded];
        for (AMQContentBody *body in self.contentBodies) {
            [encoded appendData:[[AMQFrame alloc] initWithChannelNumber:self.channelNumber payload:body].amqEncoded];
        }
    }
    return encoded;
}

- (NSData *)contentData {
    NSMutableData *allBodyData = [NSMutableData new];
    for (AMQContentBody *b in self.contentBodies) {
        [allBodyData appendData:b.data];
    }
    return allBodyData;
}

@end