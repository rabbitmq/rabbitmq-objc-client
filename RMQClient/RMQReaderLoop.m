#import "RMQReaderLoop.h"
#import "AMQProtocolMethods.h"
#import "AMQProtocolValues.h"
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
        AMQMethodDecoder *methodDecoder = [[AMQMethodDecoder alloc] initWithData:methodData];
        id<AMQMethod> method = [methodDecoder decode];

        if (method.hasContent) {
            [self.transport readFrame:^(NSData * _Nonnull headerData) {
                AMQParser *headerParser  = [[AMQParser alloc] initWithData:headerData];
                AMQFrame *header = [[AMQFrame alloc] initWithParser:headerParser];

                [self.transport readFrame:^(NSData * _Nonnull bodyData) {
                    AMQParser *bodyParser = [[AMQParser alloc] initWithData:bodyData];
                    AMQFrame *body = [[AMQFrame alloc] initWithParser:bodyParser];
                    AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:methodDecoder.channelID
                                                                            method:method
                                                                     contentHeader:header.payload
                                                                     contentBodies:@[body.payload]];
                    [self.frameHandler handleFrameset:frameset];
                }];
            }];
        } else {
            AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:methodDecoder.channelID
                                                                    method:method
                                                             contentHeader:[AMQContentHeaderNone new]
                                                             contentBodies:@[]];
            [self.frameHandler handleFrameset:frameset];
        }
    }];
}

@end
