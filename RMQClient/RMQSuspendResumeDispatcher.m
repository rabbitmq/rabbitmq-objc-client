#import "RMQSuspendResumeDispatcher.h"
#import "RMQErrors.h"

typedef NS_ENUM(NSUInteger, DispatcherState) {
    DispatcherStateOpen = 1,
    DispatcherStateClosedByClient,
    DispatcherStateClosedByServer,
};

@interface RMQSuspendResumeDispatcher ()
@property (nonatomic, readwrite) id<RMQChannel> channel;
@property (nonatomic, readwrite) id<RMQSender> sender;
@property (nonatomic, readwrite) RMQFramesetValidator *validator;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) DispatcherState state;
@end

@implementation RMQSuspendResumeDispatcher

- (instancetype)initWithSender:(id<RMQSender>)sender
                  commandQueue:(id<RMQLocalSerialQueue>)commandQueue {
    self = [super init];
    if (self) {
        self.channel = nil;
        self.sender = sender;
        self.validator = [RMQFramesetValidator new];
        self.commandQueue = commandQueue;
        self.state = DispatcherStateOpen;
    }
    return self;
}

- (void)activateWithChannel:(id<RMQChannel>)channel
                   delegate:(id<RMQConnectionDelegate>)delegate {
    self.channel = channel;
    self.delegate = delegate;
    [self.commandQueue resume];
}

- (void)blockingWaitOn:(Class)method {
    [self.commandQueue blockingEnqueue:^{
        [self processOutgoing:nil executeOrErr:^{
            [self.commandQueue suspend];
        }];
    }];

    [self.commandQueue blockingEnqueue:^{
        RMQFramesetValidationResult *result = [self.validator expect:method];
        if (result.error) {
            [self.delegate channel:self.channel error:result.error];
        }
    }];
}

- (void)sendSyncMethod:(id<RMQMethod>)method
     completionHandler:(void (^)(RMQFrameset *frameset))completionHandler {
    [self.commandQueue enqueue:^{
        [self processOutgoing:method executeOrErr:^{
            if ([self isClose:method]) {
                [self processClientClose];
            }

            RMQFrameset *outgoingFrameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                                                                method:method];
            [self.commandQueue suspend];
            [self.sender sendFrameset:outgoingFrameset];
        }];
    }];

    [self.commandQueue enqueue:^{
        RMQFramesetValidationResult *result = [self.validator expect:method.syncResponse];
        if (self.channelIsOpen && result.error) {
            [self.delegate channel:self.channel error:result.error];
        } else if (self.channelIsOpen) {
            completionHandler(result.frameset);
        }
    }];
}

- (void)sendSyncMethod:(id<RMQMethod>)method {
    [self sendSyncMethod:method
       completionHandler:^(RMQFrameset *frameset) {}];
}

- (void)sendSyncMethodBlocking:(id<RMQMethod>)method {
    [self.commandQueue blockingEnqueue:^{
        [self processOutgoing:method executeOrErr:^{
            RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];
            [self.commandQueue suspend];
            [self.sender sendFrameset:frameset];
        }];
    }];

    [self.commandQueue blockingEnqueue:^{
        RMQFramesetValidationResult *result = [self.validator expect:method.syncResponse];
        if (self.channelIsOpen && result.error) {
            [self.delegate channel:self.channel error:result.error];
        }
    }];
}

- (void)sendAsyncFrameset:(RMQFrameset *)frameset {
    [self.commandQueue enqueue:^{
        [self processOutgoing:frameset.method executeOrErr:^{
            [self.sender sendFrameset:frameset];
        }];
    }];
}

- (void)sendAsyncMethod:(id<RMQMethod>)method {
    [self sendAsyncFrameset:[[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method]];
}

- (void)handleFrameset:(RMQFrameset *)frameset {
    if (!self.channelAlreadyClosedByServer && [self isClose:frameset.method]) {
        [self processServerClose:(RMQChannelClose *)frameset.method];
    } else if (self.channelIsOpen) {
        [self.validator fulfill:frameset];
    }
    [self.commandQueue resume];
}

# pragma mark - Private

- (void)processOutgoing:(id<RMQMethod>)method
           executeOrErr:(void (^)())operation {
    if (self.channelIsOpen) {
        operation();
    } else if (![self isClose:method]) {
        [self sendChannelClosedError];
    }
}

- (void)processClientClose {
    self.state = DispatcherStateClosedByClient;
}

- (void)processServerClose:(RMQChannelClose *)close {
    self.state = DispatcherStateClosedByServer;
    NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                         code:close.replyCode.integerValue
                                     userInfo:@{NSLocalizedDescriptionKey: close.replyText.stringValue}];
    [self.delegate channel:self.channel error:error];
    [self.sender sendFrameset:[[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                                                  method:[RMQChannelCloseOk new]]];
}

- (void)sendChannelClosedError {
    NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                         code:RMQErrorChannelClosed
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot use channel after it has been closed."}];
    [self.delegate channel:self.channel error:error];
}

- (BOOL)channelIsOpen {
    return self.state == DispatcherStateOpen;
}

- (BOOL)channelAlreadyClosedByServer {
    return self.state == DispatcherStateClosedByServer;
}

- (BOOL)isClose:(id<RMQMethod>)method {
    return [method isKindOfClass:[RMQChannelClose class]];
}

- (NSNumber *)channelNumber {
    return self.channel.channelNumber;
}

@end
