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
            AMQFrame *header = [self frameWithData:headerData];

            [self readBodiesForChannelNumber:frame.channelNumber
                                      method:method
                                      header:(AMQContentHeader *)header.payload
                               contentBodies:@[]];
        }];
    } else {
        AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelNumber:frame.channelNumber
                                                                    method:method
                                                             contentHeader:[AMQContentHeaderNone new]
                                                             contentBodies:@[]];
        [self.frameHandler handleFrameset:frameset];
    }
}

- (void)readBodiesForChannelNumber:(NSNumber *)channelNumber
                        method:(id<AMQMethod>)method
                        header:(AMQContentHeader *)header
                 contentBodies:(NSArray *)contentBodies {
    [self.transport readFrame:^(NSData * _Nonnull data) {
        AMQFrame *frame = [self frameWithData:data];
        AMQFrameset *contentFrameset = [[AMQFrameset alloc] initWithChannelNumber:channelNumber
                                                                           method:method
                                                                    contentHeader:header
                                                                    contentBodies:contentBodies];

        if ([frame.payload isKindOfClass:[AMQContentBody class]]) {
            [self handlePotentiallyIncompleteFrameset:contentFrameset
                                             newFrame:frame];
        } else {
            [self.frameHandler handleFrameset:contentFrameset];
            AMQFrameset *nonContentFrameset = [[AMQFrameset alloc] initWithChannelNumber:channelNumber
                                                                                  method:(id <AMQMethod>)frame.payload
                                                                           contentHeader:[AMQContentHeaderNone new]
                                                                           contentBodies:@[]];
            [self.frameHandler handleFrameset:nonContentFrameset];
        }
    }];
}

- (void)handlePotentiallyIncompleteFrameset:(AMQFrameset *)frameset
                                   newFrame:(AMQFrame *)newFrame {
    NSArray *conjoinedContentBodies = [frameset.contentBodies arrayByAddingObject:(AMQContentBody *)newFrame.payload];
    NSNumber *finishedLength = [conjoinedContentBodies valueForKeyPath:@"@sum.length"];

    if ([frameset.contentHeader.bodySize isEqualToNumber:finishedLength]) {
        AMQFrameset *contentFrameset = [[AMQFrameset alloc] initWithChannelNumber:frameset.channelNumber
                                                                           method:frameset.method
                                                                    contentHeader:frameset.contentHeader
                                                                    contentBodies:conjoinedContentBodies];
        [self.frameHandler handleFrameset:contentFrameset];
    } else {
        [self readBodiesForChannelNumber:frameset.channelNumber
                                  method:frameset.method
                                  header:frameset.contentHeader
                           contentBodies:conjoinedContentBodies];
    }
}

- (AMQFrame *)frameWithData:(NSData *)data {
    AMQParser *parser = [[AMQParser alloc] initWithData:data];
    return [[AMQFrame alloc] initWithParser:parser];
}

@end
