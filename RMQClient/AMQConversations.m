#import "AMQConversations.h"

@implementation AMQConnectionStart (Conversation)

- (id<AMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    AMQTable *capabilities = [[AMQTable alloc] init:@{@"publisher_confirms": [[AMQBoolean alloc] init:YES],
                                                      @"consumer_cancel_notify": [[AMQBoolean alloc] init:YES],
                                                      @"exchange_exchange_bindings": [[AMQBoolean alloc] init:YES],
                                                      @"basic.nack": [[AMQBoolean alloc] init:YES],
                                                      @"connection.blocked": [[AMQBoolean alloc] init:YES],
                                                      @"authentication_failure_close": [[AMQBoolean alloc] init:YES]}];
    AMQTable *clientProperties = [[AMQTable alloc] init:
                                  @{@"capabilities" : capabilities,
                                    @"product"      : [[AMQLongstr alloc] init:@"RMQClient"],
                                    @"platform"     : [[AMQLongstr alloc] init:@"iOS"],
                                    @"version"      : [[AMQLongstr alloc] init:@"0.0.1"],
                                    @"information"  : [[AMQLongstr alloc] init:@"https://github.com/camelpunch/RMQClient"]}];

    return [[AMQConnectionStartOk alloc] initWithClientProperties:clientProperties
                                                        mechanism:[[AMQShortstr alloc] init:@"PLAIN"]
                                                         response:config.credentials
                                                           locale:[[AMQShortstr alloc] init:@"en_GB"]];
}

@end

@implementation AMQConnectionTune (Conversation)

- (id<AMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    RMQConnectionConfig *client = config;
    AMQConnectionTune *server = self;

    NSNumber *channelMax = [self negotiateBetweenClientValue:client.channelMax
                                                 serverValue:@(server.channelMax.integerValue)];
    NSNumber *frameMax   = [self negotiateBetweenClientValue:client.frameMax
                                                 serverValue:@(server.frameMax.integerValue)];
    NSNumber *heartbeat  = @0;
    return [[AMQConnectionTuneOk alloc] initWithChannelMax:[[AMQShort alloc] init:channelMax.integerValue]
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

@implementation AMQConnectionTuneOk (Conversation)

- (id<AMQMethod>)nextRequest {
    return [[AMQConnectionOpen alloc] initWithVirtualHost:[[AMQShortstr alloc] init:@"/"]
                                                reserved1:[[AMQShortstr alloc] init:@""]
                                                  options:0];
}

@end

@implementation AMQConnectionClose (Conversation)

- (id<AMQMethod>)replyWithConfig:(RMQConnectionConfig *)config {
    return [AMQConnectionCloseOk new];
}

@end
