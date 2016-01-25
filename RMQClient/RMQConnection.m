#import "RMQConnection.h"
#import "AMQMethodFrame.h"
#import "AMQEncoder.h"
#import "AMQCredentials.h"
#import "AMQRFC2595Encoder.h"

@interface RMQConnection ()
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (nonatomic, readwrite) id <RMQTransport> transport;
@property (nonatomic, readwrite) NSDictionary *clientProperties;
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
        self.clientProperties = @{@"capabilities" : @{
                                          @"publisher_confirms"           : @(YES),
                                          @"consumer_cancel_notify"       : @(YES),
                                          @"exchange_exchange_bindings"   : @(YES),
                                          @"basic.nack"                   : @(YES),
                                          @"connection.blocked"           : @(YES),
                                          @"authentication_failure_close" : @(YES)},
                                  @"product"     : @"RMQClient",
                                  @"platform"    : @"iOS",
                                  @"version"     : @"0.0.1",
                                  @"information" : @"https://github.com/camelpunch/RMQClient"};
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
    char *buffer = malloc(8);
    memcpy(buffer, "AMQP", strlen("AMQP"));
    buffer[4] = 0x00;
    buffer[5] = 0x00;
    buffer[6] = 0x09;
    buffer[7] = 0x01;
    
    NSData *protocolHeader = [NSData dataWithBytesNoCopy:buffer length:8];
    
    [self.transport write:protocolHeader onComplete:^{
        [self.transport readFrame:^(NSData * _Nonnull startData) {
            AMQMethodFrame *frame = [AMQMethodFrame new];
            [frame parse:startData];
            // TODO: check the result of the above, which ought to be a ConnectionStart
            
            AMQEncoder *encoder = [AMQEncoder new];
            AMQRFC2595Encoder *rfc2595Encoder = [AMQRFC2595Encoder new];
            [self.credentials encodeWithCoder:rfc2595Encoder];
            
            AMQProtocolConnectionStartOk *startOk = [[AMQProtocolConnectionStartOk alloc]
                                                     initWithClientProperties:self.clientProperties
                                                     mechanism:self.mechanism
                                                     response:rfc2595Encoder.data
                                                     locale:self.locale];
            
            [startOk encodeWithCoder:encoder];
            [self.transport write:encoder.data onComplete:^{
                
            }];
        }];
    }];
}

- (void)close {
    
}

- (RMQChannel *)createChannel {
    return [RMQChannel new];
}

@end
