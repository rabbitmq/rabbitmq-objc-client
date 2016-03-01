#import "AMQFrameset.h"
#import "AMQFrame.h"

@interface AMQFrameset ()
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (nonatomic, readwrite) id<AMQMethod> method;
@property (nonatomic, readwrite) AMQContentHeader *contentHeader;
@property (nonatomic, readwrite) NSArray *contentBodies;
@end

@implementation AMQFrameset

- (instancetype)initWithChannelID:(NSNumber *)channelID
                           method:(id<AMQMethod>)method
                    contentHeader:(AMQContentHeader *)contentHeader
                    contentBodies:(NSArray *)contentBodies {
    self = [super init];
    if (self) {
        self.channelID = channelID;
        self.method = method;
        self.contentHeader = contentHeader;
        self.contentBodies = contentBodies;
    }
    return self;
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQFrame alloc] initWithChannelID:self.channelID payload:self.method].amqEncoded];
    NSData *contentHeaderEncoded = self.contentHeader.amqEncoded;
    if (contentHeaderEncoded.length) {
        [encoded appendData:[[AMQFrame alloc] initWithChannelID:self.channelID payload:self.contentHeader].amqEncoded];
        for (AMQContentBody *body in self.contentBodies) {
            [encoded appendData:[[AMQFrame alloc] initWithChannelID:self.channelID payload:body].amqEncoded];
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