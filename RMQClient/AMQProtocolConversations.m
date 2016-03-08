#import "AMQProtocolConversations.h"

@implementation AMQProtocolConnectionStart (Conversation)

- (id<AMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    AMQTable *capabilities = [[AMQTable alloc] init:@{@"publisher_confirms": [[AMQBoolean alloc] init:YES],
                                                      @"consumer_cancel_notify": [[AMQBoolean alloc] init:YES],
                                                      @"exchange_exchange_bindings": [[AMQBoolean alloc] init:YES],
                                                      @"basic.nack": [[AMQBoolean alloc] init:YES],
                                                      @"connection.blocked": [[AMQBoolean alloc] init:YES],
                                                      @"authentication_failure_close": [[AMQBoolean alloc] init:YES]}];
    AMQTable *clientProperties = [[AMQTable alloc] init:
                                  @{@"capabilities" : capabilities,
                                    @"product"     : [[AMQLongstr alloc] init:@"RMQClient"],
                                    @"platform"    : [[AMQLongstr alloc] init:@"iOS"],
                                    @"version"     : [[AMQLongstr alloc] init:@"0.0.1"],
                                    @"information" : [[AMQLongstr alloc] init:@"https://github.com/camelpunch/RMQClient"]}];

    return [[AMQProtocolConnectionStartOk alloc] initWithClientProperties:clientProperties
                                                                mechanism:[[AMQShortstr alloc] init:@"PLAIN"]
                                                                 response:config.credentials
                                                                   locale:[[AMQShortstr alloc] init:@"en_GB"]];
}

@end

@implementation AMQProtocolConnectionTune (Conversation)

- (id<AMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    RMQConnectionConfig *client = config;
    AMQProtocolConnectionTune *server = self;

    NSNumber *channelMax = [self negotiateBetweenClientValue:client.channelMax
                                                 serverValue:@(server.channelMax.integerValue)];
    NSNumber *frameMax   = [self negotiateBetweenClientValue:client.frameMax
                                                 serverValue:@(server.frameMax.integerValue)];
    NSNumber *heartbeat  = [self negotiateBetweenClientValue:client.heartbeat
                                                 serverValue:@(server.heartbeat.integerValue)];
    return [[AMQProtocolConnectionTuneOk alloc] initWithChannelMax:[[AMQShort alloc] init:channelMax.integerValue]
                                                          frameMax:[[AMQLong alloc] init:frameMax.integerValue]
                                                         heartbeat:[[AMQShort alloc] init:heartbeat.integerValue]];
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

@implementation AMQProtocolConnectionTuneOk (Conversation)

- (id<AMQMethod>)nextRequest {
    return [[AMQProtocolConnectionOpen alloc] initWithVirtualHost:[[AMQShortstr alloc] init:@"/"]
                                                        reserved1:[[AMQShortstr alloc] init:@""]
                                                          options:0];
}

@end

@implementation AMQProtocolConnectionClose (Conversation)

- (id<AMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    return [AMQProtocolConnectionCloseOk new];
}

@end
