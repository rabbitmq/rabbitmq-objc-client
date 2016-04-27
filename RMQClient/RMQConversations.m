#import "RMQConversations.h"

@implementation RMQConnectionStart (Conversation)

- (id<RMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
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
                                                         response:config.credentials
                                                           locale:[[RMQShortstr alloc] init:@"en_GB"]];
}

@end

@implementation RMQConnectionTune (Conversation)

- (id<RMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    RMQConnectionConfig *client = config;
    RMQConnectionTune *server = self;

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

- (NSNumber *)negotiateBetweenClientValue:(NSNumber *)client
                              serverValue:(NSNumber *)server {
    if ([client isEqualToNumber:@0] || [server isEqualToNumber:@0]) {
        return client.integerValue > server.integerValue ? client : server;
    } else {
        return client.integerValue < server.integerValue ? client : server;
    }
}

@end

@implementation RMQConnectionTuneOk (Conversation)

- (id<RMQMethod>)nextRequest {
    return [[RMQConnectionOpen alloc] initWithVirtualHost:[[RMQShortstr alloc] init:@"/"]
                                                reserved1:[[RMQShortstr alloc] init:@""]
                                                  options:0];
}

@end

@implementation RMQConnectionClose (Conversation)

- (id<RMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    return [RMQConnectionCloseOk new];
}

@end
