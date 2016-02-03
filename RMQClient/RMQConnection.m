#import "RMQConnection.h"
#import "AMQMethodFrame.h"
#import "AMQEncoder.h"

@interface RMQConnection ()
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (strong, nonatomic, readwrite) id <RMQTransport> transport;
@property (nonatomic, readwrite) AMQFieldTable *clientProperties;
@property (nonatomic, readwrite) NSString *mechanism;
@property (nonatomic, readwrite) NSString *locale;
@property (nonatomic, readwrite) AMQCredentials *credentials;
@end

@implementation RMQConnection

- (instancetype)initWithUser:(NSString *)user
                    password:(NSString *)password
                       vhost:(NSString *)vhost
                   transport:(id<RMQTransport>)transport {
    self = [super init];
    if (self) {
        self.credentials = [[AMQCredentials alloc] initWithUsername:user
                                                           password:password];
        self.vhost = vhost;
        self.transport = transport;
        AMQFieldTable *capabilities = [[AMQFieldTable alloc] init:@{@"publisher_confirms": [[AMQBoolean alloc] init:YES],
                                                                    @"consumer_cancel_notify": [[AMQBoolean alloc] init:YES],
                                                                    @"exchange_exchange_bindings": [[AMQBoolean alloc] init:YES],
                                                                    @"basic.nack": [[AMQBoolean alloc] init:YES],
                                                                    @"connection.blocked": [[AMQBoolean alloc] init:YES],
                                                                    @"authentication_failure_close": [[AMQBoolean alloc] init:YES]}];
        self.clientProperties = [[AMQFieldTable alloc] init:
                                 @{@"capabilities" : capabilities,
                                   @"product"     : [[AMQLongString alloc] init:@"RMQClient"],
                                   @"platform"    : [[AMQLongString alloc] init:@"iOS"],
                                   @"version"     : [[AMQLongString alloc] init:@"0.0.1"],
                                   @"information" : [[AMQLongString alloc] init:@"https://github.com/camelpunch/RMQClient"]}];
        self.mechanism = @"PLAIN";
        self.locale = @"en_GB";
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)start {
    [self.transport connect:^{
        NSError *outerError = NULL;
        [self.transport write:self.protocolHeader.amqEncoded
                        error:&outerError
                   onComplete:^{
                       [self.transport readFrame:^(NSData * _Nonnull startData) {
                           if ([self parseConnectionStart:startData]) {
                               [self sendConnectionStartOk];
                           }
                       }];
                   }];
    }];
}

- (void)close {

}

- (RMQChannel *)createChannel {
    return [RMQChannel new];
}

- (BOOL)parseConnectionStart:(NSData *)startData {
    AMQMethodFrame *frame = [AMQMethodFrame new];
    return !![frame parse:startData];
}

- (void)sendConnectionStartOk {
    AMQEncoder *encoder = [AMQEncoder new];
    AMQProtocolConnectionStartOk *startOk = [[AMQProtocolConnectionStartOk alloc]
                                             initWithClientProperties:self.clientProperties
                                             mechanism:self.mechanism
                                             response:self.credentials
                                             locale:self.locale];
    [startOk encodeWithCoder:encoder];
    NSError *innerError = NULL;
    [self.transport write:[encoder frameForClassID:@(10)
                                          methodID:@(11)]
                    error: &innerError
               onComplete:^{

               }];
}

- (AMQProtocolHeader *)protocolHeader {
    return [AMQProtocolHeader new];
}

@end
