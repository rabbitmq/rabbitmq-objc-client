#import "RMQSuspendResumeDispatcher.h"

@interface RMQSuspendResumeDispatcher ()
@property (nonatomic, readwrite) id<RMQChannel> channel;
@property (nonatomic, readwrite) id<RMQSender> sender;
@property (nonatomic, readwrite) RMQFramesetValidator *validator;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@end

@implementation RMQSuspendResumeDispatcher

- (instancetype)initWithSender:(id<RMQSender>)sender
                     validator:(RMQFramesetValidator *)validator
                  commandQueue:(id<RMQLocalSerialQueue>)commandQueue {
    self = [super init];
    if (self) {
        self.channel = nil;
        self.sender = sender;
        self.validator = validator;
        self.commandQueue = commandQueue;
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
        [self.commandQueue suspend];
    }];

    [self.commandQueue blockingEnqueue:^{
        RMQFramesetValidationResult *result = [self.validator expect:method];
        if (result.error) {
            [self.delegate channel:self.channel error:result.error];
        }
    }];
}

- (void)sendSyncMethod:(id<RMQMethod>)method
                waitOn:(Class)waitClass
     completionHandler:(void (^)(RMQFramesetValidationResult *result))completionHandler {
    [self.commandQueue enqueue:^{
        RMQFrameset *outgoingFrameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                                                            method:method];
        [self.commandQueue suspend];
        [self.sender sendFrameset:outgoingFrameset];
    }];

    [self.commandQueue enqueue:^{
        RMQFramesetValidationResult *result = [self.validator expect:waitClass];
        if (result.error) {
            [self.delegate channel:self.channel error:result.error];
        } else {
            completionHandler(result);
        }
    }];
}

- (void)sendSyncMethod:(id<RMQMethod>)method
                waitOn:(Class)waitClass {
    [self sendSyncMethod:method
                  waitOn:waitClass
       completionHandler:^(RMQFramesetValidationResult *result) {}];
}

- (void)sendSyncMethodBlocking:(id<RMQMethod>)method
                        waitOn:(Class)waitClass {
    [self.commandQueue blockingEnqueue:^{
        RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];
        [self.commandQueue suspend];
        [self.sender sendFrameset:frameset];
    }];

    [self.commandQueue blockingEnqueue:^{
        RMQFramesetValidationResult *result = [self.validator expect:[RMQChannelCloseOk class]];
        if (result.error) {
            [self.delegate channel:self.channel error:result.error];
        }
    }];
}

- (void)sendAsyncFrameset:(RMQFrameset *)frameset {
    [self.commandQueue enqueue:^{
        [self.sender sendFrameset:frameset];
    }];
}

- (void)sendAsyncMethod:(id<RMQMethod>)method {
    [self sendAsyncFrameset:[[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method]];
}

- (void)handleFrameset:(RMQFrameset *)frameset {
    [self.validator fulfill:frameset];
    [self.commandQueue resume];
}

# pragma mark - Private

- (NSNumber *)channelNumber {
    return self.channel.channelNumber;
}

@end
