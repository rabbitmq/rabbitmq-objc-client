#import "RMQReaderLoop.h"
#import "AMQProtocolMethods.h"
#import "AMQDecoder.h"

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
    [self.transport readFrame:^(NSData * _Nonnull responseData) {
        AMQDecoder *decoder = [[AMQDecoder alloc] initWithData:responseData];
        id<AMQMethod> method = [decoder decode];
        AMQFrameset *frameset = [[AMQFrameset alloc] initWithChannelID:decoder.channelID
                                                                method:method
                                                         contentHeader:[AMQContentHeader new]
                                                         contentBodies:@[]];
        [self.frameHandler handleFrameset:frameset];
    }];
}

@end
