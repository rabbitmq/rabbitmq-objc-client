#import "RMQHandshaker.h"

@interface RMQHandshaker ()
@property (nonatomic, readwrite) id<RMQSender> sender;
@property (nonatomic, readwrite) RMQConnectionConfig *config;
@property (nonatomic, readwrite) void (^completionHandler)(NSNumber *heartbeatTimeout);
@property (nonatomic, readwrite) NSNumber *heartbeatTimeout;
@end

@implementation RMQHandshaker

- (instancetype)initWithSender:(id<RMQSender>)sender
                        config:(RMQConnectionConfig *)config
             completionHandler:(void (^)(NSNumber *heartbeatTimeout))completionHandler {
    self = [super init];
    if (self) {
        self.sender = sender;
        self.config = config;
        self.completionHandler = completionHandler;
        self.heartbeatTimeout = @0;
    }
    return self;
}

- (void)handleFrameset:(RMQFrameset *)frameset {
    id method = frameset.method;
    if ([method isKindOfClass:[RMQConnectionStart class]]) {
        [self sendMethod:self.startOk channelNumber:frameset.channelNumber];
        [self.reader run];
    } else if ([method isKindOfClass:[RMQConnectionTune class]]) {
        RMQConnectionTuneOk *tuneOk = [self tuneOkForTune:method];
        self.heartbeatTimeout = @(tuneOk.heartbeat.integerValue);

        [self sendMethod:tuneOk channelNumber:frameset.channelNumber];
        [self sendMethod:self.connectionOpen channelNumber:frameset.channelNumber];
        [self.reader run];
    } else {
        self.completionHandler(self.heartbeatTimeout);
    }
}

#pragma mark - Private

- (RMQConnectionStartOk *)startOk {
    RMQBoolean *yes = [[RMQBoolean alloc] init:YES];
    RMQTable *capabilities = [[RMQTable alloc] init:@{@"publisher_confirms"           : yes,
                                                      @"consumer_cancel_notify"       : yes,
                                                      @"exchange_exchange_bindings"   : yes,
                                                      @"basic.nack"                   : yes,
                                                      @"connection.blocked"           : yes,
                                                      @"authentication_failure_close" : yes}];

    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"io.pivotal.RMQClient"];
    NSString *version = bundle.infoDictionary[@"CFBundleShortVersionString"];

    RMQTable *clientProperties = [[RMQTable alloc] init:
                                  @{@"capabilities" : capabilities,
                                    @"product"      : [[RMQLongstr alloc] init:@"RMQClient"],
                                    @"platform"     : [[RMQLongstr alloc] init:@"iOS"],
                                    @"version"      : [[RMQLongstr alloc] init:version],
                                    @"information"  : [[RMQLongstr alloc] init:@"https://github.com/rabbitmq/rabbitmq-objc-client"]}];

    return [[RMQConnectionStartOk alloc] initWithClientProperties:clientProperties
                                                        mechanism:[[RMQShortstr alloc] init:self.config.authMechanism]
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
    return [[RMQConnectionOpen alloc] initWithVirtualHost:[[RMQShortstr alloc] init:self.config.vhost]
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
    [self.sender sendFrameset:frameset force:YES];
}

@end
