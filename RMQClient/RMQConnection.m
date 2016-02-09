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
                           [self readResponse:responseData expectedResponseClass:[AMQProtocolConnectionStart class]];
                       }];
                   }];
    }];
    return self;
}

- (void)close {
    [self.transport close:^{}];
}

- (RMQChannel *)createChannel {
    RMQChannel *ch = [[RMQChannel new] open];
    [self send:[[AMQProtocolChannelOpen alloc] initWithReserved1:[[AMQShortstr alloc] init:@""]]];
    return ch;
}

# pragma mark - Private

- (void)send:(id<AMQOutgoing,AMQMethod>)amqMethod {
    AMQEncoder *encoder = [AMQEncoder new];
    NSError *error = NULL;
    [self.transport write:[encoder encodeMethod:amqMethod]
                    error:&error
               onComplete:^{
                   if (amqMethod.expectedResponseClass) {
                       [self.transport readFrame:^(NSData * _Nonnull responseData) {
                           [self readResponse:responseData expectedResponseClass:amqMethod.expectedResponseClass];
                       }];
                   } else if (amqMethod.nextRequest) {
                       [self send:amqMethod.nextRequest];
                   }
               }];
}

- (void)readResponse:(NSData *)responseData expectedResponseClass:(Class)expectedResponseClass {
    if (responseData.length) {
        AMQDecoder *decoder = [[AMQDecoder alloc] initWithData:responseData];
        id<AMQIncoming> parsedResponse = [[expectedResponseClass alloc] initWithCoder:decoder];
        id<AMQOutgoing,AMQMethod> reply = [parsedResponse replyWithContext:self];
        if (reply) {
            [self send:reply];
        }
    }
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
