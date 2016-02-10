#import "RMQConnection.h"
#import "AMQEncoder.h"
#import "AMQDecoder.h"
#import "AMQProtocolHeader.h"
#import "AMQProtocolMethods.h"

@interface RMQConnection ()
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (strong, nonatomic, readwrite) id <RMQTransport> transport;
@property (nonatomic, readwrite) AMQTable *clientProperties;
@property (nonatomic, readwrite) NSString *mechanism;
@property (nonatomic, readwrite) NSString *locale;
@property (nonatomic, readwrite) AMQCredentials *credentials;
@property (nonatomic, readwrite) RMQChannel *channelZero;
@property (nonatomic, readwrite) id <RMQIDAllocator> idAllocator;
@end

@implementation RMQConnection

- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id<RMQTransport>)transport
                 idAllocator:(id<RMQIDAllocator>)idAllocator {
    self = [super init];
    if (self) {
        self.credentials = [[AMQCredentials alloc] initWithUsername:user
                                                           password:password];
        self.vhost = vhost;
        self.transport = transport;
        self.idAllocator = idAllocator;
        AMQTable *capabilities = [[AMQTable alloc] init:@{@"publisher_confirms": [[AMQBoolean alloc] init:YES],
                                                                    @"consumer_cancel_notify": [[AMQBoolean alloc] init:YES],
                                                                    @"exchange_exchange_bindings": [[AMQBoolean alloc] init:YES],
                                                                    @"basic.nack": [[AMQBoolean alloc] init:YES],
                                                                    @"connection.blocked": [[AMQBoolean alloc] init:YES],
                                                                    @"authentication_failure_close": [[AMQBoolean alloc] init:YES]}];
        self.clientProperties = [[AMQTable alloc] init:
                                 @{@"capabilities" : capabilities,
                                   @"product"     : [[AMQLongstr alloc] init:@"RMQClient"],
                                   @"platform"    : [[AMQLongstr alloc] init:@"iOS"],
                                   @"version"     : [[AMQLongstr alloc] init:@"0.0.1"],
                                   @"information" : [[AMQLongstr alloc] init:@"https://github.com/camelpunch/RMQClient"]}];
        self.mechanism = @"PLAIN";
        self.locale = @"en_GB";
        self.channelZero = [[RMQChannel alloc] init:@(0)];
    }
    return self;
}

- (RMQConnection *)start {
    [self.transport connect:^{
        NSError *error = NULL;
        [self.transport write:[AMQProtocolHeader new].amqEncoded
                        error:&error
                   onComplete:^{
                       [self.transport readFrame:^(NSData * _Nonnull responseData) {
                           [self readResponse:responseData
                        expectedResponseClass:[AMQProtocolConnectionStart class]
                                      channel:self.channelZero];
                       }];
                   }];
    }];
    return self;
}

- (void)close {
    [self send:[[AMQProtocolConnectionClose alloc] initWithReplyCode:[[AMQShort alloc] init:200]
                                                           replyText:[[AMQShortstr alloc] init:@"Goodbye"]
                                                             classId:[[AMQShort alloc] init:0]
                                                            methodId:[[AMQShort alloc] init:0]]
       channel:self.channelZero];
    [self.transport close:^{}];
}

- (RMQChannel *)createChannel {
    RMQChannel *ch = [[RMQChannel alloc] init:[self.idAllocator nextID]];
    [self send:[[AMQProtocolChannelOpen alloc] initWithReserved1:[[AMQShortstr alloc] init:@""]]
       channel:ch];
    return ch;
}

# pragma mark - Private

- (void)send:(id<AMQMethod>)amqMethod
     channel:(RMQChannel *)channel {
    AMQEncoder *encoder = [AMQEncoder new];
    NSError *error = NULL;
    [self.transport write:[encoder encodeMethod:amqMethod
                                      channelID:channel.channelID]
                    error:&error
               onComplete:^{
                   if ([amqMethod conformsToProtocol:@protocol(AMQOutgoingSync)]) {
                       [self.transport readFrame:^(NSData * _Nonnull responseData) {
                           [self readResponse:responseData
                        expectedResponseClass:((id <AMQOutgoingSync>)amqMethod).expectedResponseClass
                                      channel:channel];
                       }];
                   } else if ([amqMethod conformsToProtocol:@protocol(AMQOutgoingPrecursor)]) {
                       [self send:((id <AMQOutgoingPrecursor>)amqMethod).nextRequest channel:channel];
                   }
               }];
}

-  (void)readResponse:(NSData *)responseData
expectedResponseClass:(Class)expectedResponseClass
              channel:(RMQChannel *)channel {
    if (responseData.length) {
        AMQDecoder *decoder = [[AMQDecoder alloc] initWithData:responseData];
        id parsedResponse = [[expectedResponseClass alloc] initWithCoder:decoder];
        if ([parsedResponse conformsToProtocol:@protocol(AMQIncomingCallback)]) {
            [parsedResponse didReceiveOnChannel:channel];
        }
        if ([parsedResponse conformsToProtocol:@protocol(AMQIncomingSync)]) {
            id<AMQMethod> reply = [parsedResponse replyWithContext:self];
            [self send:reply channel:channel];
        }
    }
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
