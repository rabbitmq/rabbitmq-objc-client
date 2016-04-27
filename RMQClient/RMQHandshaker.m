#import "RMQHandshaker.h"

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
    if ([method isKindOfClass:[RMQConnectionStart class]]) {
        [self sendMethod:self.startOk channelNumber:frameset.channelNumber];
        [self.readerLoop runOnce];
    } else if ([method isKindOfClass:[RMQConnectionTune class]]) {
        [self sendMethod:[self tuneOkForTune:method] channelNumber:frameset.channelNumber];
        [self sendMethod:self.connectionOpen channelNumber:frameset.channelNumber];
        [self.readerLoop runOnce];
    } else {
        self.completionHandler();
    }
}

#pragma mark - Private

- (RMQConnectionStartOk *)startOk {
    RMQTable *capabilities = [[RMQTable alloc] init:@{@"publisher_confirms": [[RMQBoolean alloc] init:YES],
                                                      @"consumer_cancel_notify": [[RMQBoolean alloc] init:YES],
                                                      @"exchange_exchange_bindings": [[RMQBoolean alloc] init:YES],
                                                      @"basic.nack": [[RMQBoolean alloc] init:YES],
                                                      @"connection.blocked": [[RMQBoolean alloc] init:YES],
                                                      @"authentication_failure_close": [[RMQBoolean alloc] init:YES]}];
    RMQTable *clientProperties = [[RMQTable alloc] init:
                                  @{@"capabilities" : capabilities,
                                    @"product"      : [[RMQLongstr alloc] init:@"RMQClient"],
                                    @"platform"     : [[RMQLongstr alloc] init:@"iOS"],
                                    @"version"      : [[RMQLongstr alloc] init:@"0.0.1"],
                                    @"information"  : [[RMQLongstr alloc] init:@"https://github.com/camelpunch/RMQClient"]}];

    return [[RMQConnectionStartOk alloc] initWithClientProperties:clientProperties
                                                        mechanism:[[RMQShortstr alloc] init:@"PLAIN"]
                                                         response:self.config.credentials
                                                           locale:[[RMQShortstr alloc] init:@"en_GB"]];
}

- (RMQConnectionTuneOk *)tuneOkForTune:(RMQConnectionTune *)tune {
    RMQConnectionConfig *client = self.config;
    RMQConnectionTune *server = tune;

    NSNumber *channelMax = [self negotiateBetweenClientValue:client.channelMax
                                                 serverValue:@(server.channelMax.integerValue)];
    NSNumber *frameMax   = [self negotiateBetweenClientValue:client.frameMax
                                                 serverValue:@(server.frameMax.integerValue)];
    NSNumber *heartbeat  = [self negotiateBetweenClientValue:client.heartbeat
                                                 serverValue:@(server.heartbeat.integerValue)];
    return [[RMQConnectionTuneOk alloc] initWithChannelMax:[[RMQShort alloc] init:channelMax.integerValue]
                                                  frameMax:[[RMQLong alloc] init:frameMax.integerValue]
                                                 heartbeat:[[RMQShort alloc] init:heartbeat.integerValue]];
}

- (RMQConnectionOpen *)connectionOpen {
    return [[RMQConnectionOpen alloc] initWithVirtualHost:[[RMQShortstr alloc] init:@"/"]
                                                reserved1:[[RMQShortstr alloc] init:@""]
                                                  options:0];
}

- (NSNumber *)negotiateBetweenClientValue:(NSNumber *)client
                              serverValue:(NSNumber *)server {
    if ([client isEqualToNumber:@0] || [server isEqualToNumber:@0]) {
        return client.integerValue > server.integerValue ? client : server;
    } else {
        return client.integerValue < server.integerValue ? client : server;
    }
}

- (void)sendMethod:(id<RMQMethod>)amqMethod channelNumber:(NSNumber *)channelNumber {
    RMQFrameset *frameset = [[RMQFrameset alloc] initWithChannelNumber:channelNumber method:amqMethod];
    [self.sender sendFrameset:frameset];
}

@end
