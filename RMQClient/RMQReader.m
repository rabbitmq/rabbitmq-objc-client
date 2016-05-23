#import "RMQReader.h"
#import "RMQFrame.h"
#import "RMQMethodDecoder.h"

@interface RMQReader ()
@property (nonatomic, readwrite) id<RMQTransport>transport;
@property (nonatomic, readwrite) id<RMQFrameHandler>frameHandler;
@end

@implementation RMQReader

- (instancetype)initWithTransport:(id<RMQTransport>)transport frameHandler:(id<RMQFrameHandler>)frameHandler {
    self = [super init];
    if (self) {
        self.transport = transport;
        self.frameHandler = frameHandler;
    }
    return self;
}

- (void)run {
    [self.transport readFrame:^(NSData * _Nonnull methodData) {
        // executing on a concurrent queue
        
        RMQFrame *frame = [self frameWithData:methodData];

        if (frame.isHeartbeat) {
            [self run];
        } else {
            [self handleMethodFrame:frame];
        }
    }];
}

# pragma mark - Private

- (void)handleMethodFrame:(RMQFrame *)frame {
    id<RMQMethod> method = (id<RMQMethod>)frame.payload;

    if (method.hasContent) {
        [self.transport readFrame:^(NSData * _Nonnull headerData) {
            RMQFrame *headerFrame = [self frameWithData:headerData];
            RMQContentHeader *header = (RMQContentHeader *)headerFrame.payload;

            RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:frame.channelNumber
                                                                        method:method
                                                                 contentHeader:header
                                                                 contentBodies:@[]];
            if ([header.bodySize isEqualToNumber:@0]) {
                [self.frameHandler handleFrameset:frameset];
            } else {
                [self readBodiesForIncompleteFrameset:frameset];
            }
        }];
    } else {
        RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:frame.channelNumber
                                                                    method:method];
        [self.frameHandler handleFrameset:frameset];
    }
}

- (void)readBodiesForIncompleteFrameset:(RMQFrameset *)contentFrameset {
    [self.transport readFrame:^(NSData * _Nonnull data) {
        RMQFrame *frame = [self frameWithData:data];

        if ([frame.payload isKindOfClass:[RMQContentBody class]]) {
            [self frameset:contentFrameset
              addBodyFrame:frame];
        } else {
            [self.frameHandler handleFrameset:contentFrameset];
            RMQFrameset *nonContentFrameset = [[RMQFrameset alloc] initWithChannelNumber:contentFrameset.channelNumber
                                                                                  method:(id <RMQMethod>)frame.payload];
            [self.frameHandler handleFrameset:nonContentFrameset];
        }
    }];
}

- (void)frameset:(RMQFrameset *)frameset
    addBodyFrame:(RMQFrame *)newFrame {
    RMQFrameset *combinedFrameset = [frameset addBody:(RMQContentBody *)newFrame.payload];

    if (frameset.contentHeader.bodySize.integerValue == combinedFrameset.contentData.length) {
        [self.frameHandler handleFrameset:combinedFrameset];
    } else {
        [self readBodiesForIncompleteFrameset:combinedFrameset];
    }
}

- (RMQFrame *)frameWithData:(NSData *)data {
    RMQParser *parser = [[RMQParser alloc] initWithData:data];
    return [[RMQFrame alloc] initWithParser:parser];
}

@end
