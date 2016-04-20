#import "RMQHandshaker.h"
#import "RMQMethods.h"

@interface RMQHandshaker ()
@property (nonatomic, readwrite) id<RMQSender> sender;
@property (nonatomic, readwrite) RMQConnectionConfig *config;
@property (nonatomic, readwrite) void (^completionHandler)();
@end

@implementation RMQHandshaker

- (instancetype)initWithSender:(id<RMQSender>)sender
                        config:(RMQConnectionConfig *)config
             completionHandler:(void (^)())completionHandler {
    self = [super init];
    if (self) {
        self.sender = sender;
        self.config = config;
        self.completionHandler = completionHandler;
    }
    return self;
}

- (void)handleFrameset:(RMQFrameset *)frameset {
    id method = frameset.method;
    if ([self shouldReply:method]) {
        id<RMQMethod> reply = [method replyWithConfig:self.config];
        [self.sender sendMethod:reply channelNumber:frameset.channelNumber];
        [self.readerLoop runOnce];
    } else {
        self.completionHandler();
    }
}

#pragma mark - Private

- (BOOL)shouldReply:(id<RMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(RMQIncomingSync)];
}

@end
