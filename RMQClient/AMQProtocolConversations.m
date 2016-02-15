#import "AMQProtocolConversations.h"

@implementation AMQProtocolConnectionStart (Conversation)

- (id<AMQMethod>)replyWithContext:(id<AMQReplyContext>)context {
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
                                                                 response:context.credentials
                                                                   locale:[[AMQShortstr alloc] init:@"en_GB"]];
}

@end

@implementation AMQProtocolConnectionStartOk (Conversation)
@end

@implementation AMQProtocolConnectionTune (Conversation)

- (id<AMQMethod>)replyWithContext:(id<AMQReplyContext>)context {
    return [[AMQProtocolConnectionTuneOk alloc] initWithChannelMax:self.channelMax
                                                          frameMax:self.frameMax
                                                         heartbeat:self.heartbeat];
}

@end

@implementation AMQProtocolConnectionTuneOk (Conversation)

- (id<AMQMethod>)nextRequest {
    return [[AMQProtocolConnectionOpen alloc] initWithVirtualHost:[[AMQShortstr alloc] init:@"/"]
                                                        reserved1:[[AMQShortstr alloc] init:@""]
                                                        reserved2:[[AMQBit alloc] init:0]];
}

@end

@implementation AMQProtocolConnectionOpen (Conversation)
@end

@implementation AMQProtocolChannelOpen (Conversation)
@end

@implementation AMQProtocolConnectionClose (Conversation)

- (id<AMQMethod>)replyWithContext:(id<AMQReplyContext>)context {
    return [AMQProtocolConnectionCloseOk new];
}

- (void)didReceiveWithContext:(id<AMQIncomingCallbackContext>)context {
    [context close:^{

    }];
}

@end

@implementation AMQProtocolConnectionCloseOk (Conversation)

- (void)didReceiveWithContext:(id<AMQIncomingCallbackContext>)context {
    [context close:^{

    }];
}

@end