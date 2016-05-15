#import "RMQSuspendResumeDispatcher.h"
#import "RMQErrors.h"

@interface RMQSuspendResumeDispatcher ()
@property (nonatomic, readwrite) id<RMQChannel> channel;
@property (nonatomic, readwrite) id<RMQSender> sender;
@property (nonatomic, readwrite) RMQFramesetValidator *validator;
@property (nonatomic, readwrite) id<RMQLocalSerialQueue> commandQueue;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@property (nonatomic, readwrite) BOOL channelCloseRequested;
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
        self.channelCloseRequested = NO;
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
        [self checkNotAlreadyClosed:^{
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
     completionHandler:(void (^)(RMQFramesetValidationResult *result))completionHandler {
    [self.commandQueue enqueue:^{
        [self checkNotAlreadyClosed:^{
            if ([method isKindOfClass:[RMQChannelClose class]]) {
                self.channelCloseRequested = YES;
            }

            RMQFrameset *outgoingFrameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber
                                                                                method:method];
            [self.commandQueue suspend];
            [self.sender sendFrameset:outgoingFrameset];
        }];
    }];

    [self.commandQueue enqueue:^{
        if (!self.channelCloseRequested) {
            RMQFramesetValidationResult *result = [self.validator expect:method.syncResponse];
            if (result.error) {
                [self.delegate channel:self.channel error:result.error];
            } else {
                completionHandler(result);
            }
        }
    }];
}

- (void)sendSyncMethod:(id<RMQMethod>)method {
    [self sendSyncMethod:method
       completionHandler:^(RMQFramesetValidationResult *result) {}];
}

- (void)sendSyncMethodBlocking:(id<RMQMethod>)method {
    [self.commandQueue blockingEnqueue:^{
        [self checkNotAlreadyClosed:^{
            RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:self.channelNumber method:method];
            [self.commandQueue suspend];
            [self.sender sendFrameset:frameset];
        }];
    }];

    [self.commandQueue blockingEnqueue:^{
        RMQFramesetValidationResult *result = [self.validator expect:method.syncResponse];
        if (result.error) {
            [self.delegate channel:self.channel error:result.error];
        }
    }];
}

- (void)sendAsyncFrameset:(RMQFrameset *)frameset {
    [self.commandQueue enqueue:^{
        [self checkNotAlreadyClosed:^{
            [self.sender sendFrameset:frameset];
        }];
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

- (void)checkNotAlreadyClosed:(void (^)())operation {
    if (self.channelCloseRequested) {
        [self sendChannelClosedError];
    } else {
        operation();
    }
}

- (void)sendChannelClosedError {
    NSError *error = [NSError errorWithDomain:RMQErrorDomain
                                         code:RMQErrorChannelClosed
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot use channel after it has been closed."}];
    [self.delegate channel:self.channel error:error];
}

@end
