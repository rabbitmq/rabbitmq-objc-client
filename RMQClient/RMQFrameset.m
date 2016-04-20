#import "RMQFrameset.h"
#import "RMQFrame.h"

@interface RMQFrameset ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<RMQMethod> method;
@property (nonatomic, readwrite) RMQContentHeader *contentHeader;
@property (nonatomic, readwrite) NSArray *contentBodies;
@end

@implementation RMQFrameset

- (instancetype)initWithChannelNumber:(NSNumber *)channelNumber
                               method:(id<RMQMethod>)method
                        contentHeader:(RMQContentHeader *)contentHeader
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

- (instancetype)initWithChannelNumber:(NSNumber *)channelNumber
                               method:(id<RMQMethod>)method {
    return [self initWithChannelNumber:channelNumber
                                method:method
                         contentHeader:[RMQContentHeaderNone new]
                         contentBodies:@[]];
}

- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQFrame alloc] initWithChannelNumber:self.channelNumber payload:self.method].amqEncoded];
    NSData *contentHeaderEncoded = self.contentHeader.amqEncoded;
    if (contentHeaderEncoded.length) {
        [encoded appendData:[[RMQFrame alloc] initWithChannelNumber:self.channelNumber payload:self.contentHeader].amqEncoded];
        for (RMQContentBody *body in self.contentBodies) {
            [encoded appendData:[[RMQFrame alloc] initWithChannelNumber:self.channelNumber payload:body].amqEncoded];
        }
    }
    return encoded;
}

- (NSData *)contentData {
    NSMutableData *allBodyData = [NSMutableData new];
    for (RMQContentBody *b in self.contentBodies) {
        [allBodyData appendData:b.data];
    }
    return allBodyData;
}

- (RMQFrameset *)addBody:(RMQContentBody *)body {
    NSArray *conjoinedContentBodies = [self.contentBodies arrayByAddingObject:body];

    return [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                               method:self.method
                                        contentHeader:self.contentHeader
                                        contentBodies:conjoinedContentBodies];
}

@end