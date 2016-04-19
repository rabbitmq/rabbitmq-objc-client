#import "RMQReaderLoop.h"
#import "AMQFrame.h"
#import "AMQMethodDecoder.h"

@interface RMQReaderLoop ()
@property (nonatomic, readwrite) id<RMQTransport>transport;
@property (nonatomic, readwrite) id<RMQFrameHandler>frameHandler;
@end

@implementation RMQReaderLoop

- (instancetype)initWithTransport:(id<RMQTransport>)transport frameHandler:(id<RMQFrameHandler>)frameHandler {
    self = [super init];
    if (self) {
        self.transport = transport;
        self.frameHandler = frameHandler;
    }
    return self;
}

- (void)runOnce {
    [self.transport readFrame:^(NSData * _Nonnull methodData) {
        // executing on a concurrent queue
        
        AMQFrame *frame = [self frameWithData:methodData];

        if (frame.isHeartbeat) {
            [self runOnce];
        } else {
            [self handleMethodFrame:frame];
        }
    }];
}

# pragma mark - Private

- (void)handleMethodFrame:(AMQFrame *)frame {
    id<AMQMethod> method = (id<AMQMethod>)frame.payload;

    if (method.hasContent) {
        [self.transport readFrame:^(NSData * _Nonnull headerData) {
            AMQFrame *headerFrame = [self frameWithData:headerData];
            AMQContentHeader *header = (AMQContentHeader *)headerFrame.payload;

            AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:frame.channelNumber
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
        AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:frame.channelNumber
                                                                    method:method];
        [self.frameHandler handleFrameset:frameset];
    }
}

- (void)readBodiesForIncompleteFrameset:(AMQFrameset *)contentFrameset {
    [self.transport readFrame:^(NSData * _Nonnull data) {
        AMQFrame *frame = [self frameWithData:data];

        if ([frame.payload isKindOfClass:[AMQContentBody class]]) {
            [self frameset:contentFrameset
              addBodyFrame:frame];
        } else {
            [self.frameHandler handleFrameset:contentFrameset];
            AMQFrameset *nonContentFrameset = [[AMQFrameset alloc] initWithChannelNumber:contentFrameset.channelNumber
                                                                                  method:(id <AMQMethod>)frame.payload];
            [self.frameHandler handleFrameset:nonContentFrameset];
        }
    }];
}

- (void)frameset:(AMQFrameset *)frameset
    addBodyFrame:(AMQFrame *)newFrame {
    AMQFrameset *combinedFrameset = [frameset addBody:(AMQContentBody *)newFrame.payload];

    if (frameset.contentHeader.bodySize.integerValue == combinedFrameset.contentData.length) {
        [self.frameHandler handleFrameset:combinedFrameset];
    } else {
        [self readBodiesForIncompleteFrameset:combinedFrameset];
    }
}

- (AMQFrame *)frameWithData:(NSData *)data {
    AMQParser *parser = [[AMQParser alloc] initWithData:data];
    return [[AMQFrame alloc] initWithParser:parser];
}

@end
