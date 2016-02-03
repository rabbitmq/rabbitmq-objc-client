#import "RMQConnection.h"
#import "AMQMethodFrame.h"
#import "AMQEncoder.h"
#import "AMQCredentials.h"

@interface RMQConnection ()
@property (copy, nonatomic, readwrite) NSString *vhost;
@property (strong, nonatomic, readwrite) id <RMQTransport> transport;
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
                                          @"publisher_confirms": [AMQTrue new],
                                          @"consumer_cancel_notify": [AMQTrue new],
                                          @"exchange_exchange_bindings": [AMQTrue new],
                                          @"basic.nack": [AMQTrue new],
                                          @"connection.blocked": [AMQTrue new],
                                          @"authentication_failure_close": [AMQTrue new],
                                          },
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
    [self.transport connect:^{
        NSError *outerError = NULL;
        [self.transport write:self.protocolHeader
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

- (NSData *)protocolHeader {
    char *buffer = malloc(8);
    memcpy(buffer, "AMQP", strlen("AMQP"));
    buffer[4] = 0x00;
    buffer[5] = 0x00;
    buffer[6] = 0x09;
    buffer[7] = 0x01;
    return [NSData dataWithBytesNoCopy:buffer length:8];
}

@end
