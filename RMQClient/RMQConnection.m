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
                                          @"type": @"field-table",
                                          @"value": @{
                                                  @"publisher_confirms": @{@"type": @"boolean", @"value": @(YES)},
                                                  @"consumer_cancel_notify": @{@"type": @"boolean", @"value": @(YES)},                                                  @"exchange_exchange_bindings": @{@"type": @"boolean", @"value": @(YES)},                                                  @"basic.nack": @{@"type": @"boolean", @"value": @(YES)},                                                  @"connection.blocked": @{@"type": @"boolean", @"value": @(YES)},                                                  @"authentication_failure_close": @{@"type": @"boolean", @"value": @(YES)},
                                                  },
                                          },
                                  @"product"     : @{@"type": @"long-string", @"value": @"RMQClient"},
                                  @"platform"    : @{@"type": @"long-string", @"value": @"iOS"},
                                  @"version"     : @{@"type": @"long-string", @"value": @"0.0.1"},
                                  @"information" : @{@"type": @"long-string", @"value": @"https://github.com/camelpunch/RMQClient"}};
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
        char *buffer = malloc(8);
        memcpy(buffer, "AMQP", strlen("AMQP"));
        buffer[4] = 0x00;
        buffer[5] = 0x00;
        buffer[6] = 0x09;
        buffer[7] = 0x01;
        NSError *outerError = NULL;
        
        NSData *protocolHeader = [NSData dataWithBytesNoCopy:buffer length:8];
        [self.transport write:protocolHeader
                        error:&outerError
                   onComplete:^{
                       [self.transport readFrame:^(NSData * _Nonnull startData) {
                           NSError *innerError = NULL;
                           
                           AMQMethodFrame *frame = [AMQMethodFrame new];
                           AMQProtocolConnectionStart *connectionStart = [frame parse:startData];
                           
                           if (!connectionStart) {
                               return;
                           }
                           
                           AMQEncoder *encoder = [AMQEncoder new];
                           
                           AMQProtocolConnectionStartOk *startOk = [[AMQProtocolConnectionStartOk alloc]
                                                                    initWithClientProperties:self.clientProperties
                                                                    mechanism:self.mechanism
                                                                    response:self.credentials
                                                                    locale:self.locale];
                           
                           [startOk encodeWithCoder:encoder];
                           [self.transport write:encoder.data
                                           error: &innerError
                                      onComplete:^{
                                          
                                      }];
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
