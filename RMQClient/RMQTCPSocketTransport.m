#import "RMQTCPSocketTransport.h"

@interface RMQTCPSocketTransport ()
@property (nonnull, nonatomic, readwrite) NSString *host;
@property (nonnull, nonatomic, readwrite) NSNumber *port;
@property (nonatomic, readwrite) BOOL _isConnected;
@property (nonnull, nonatomic, readwrite) GCDAsyncSocket *socket;
@end

@implementation RMQTCPSocketTransport

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port {
    self = [super init];
    if (self) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.host = host;
        self.port = port;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)connect {
    NSError *error = nil;
    if (![self.socket connectToHost:self.host onPort:self.port.unsignedIntegerValue error:&error]) {
        NSLog(@"*************** Something is very wrong: %@", error);
    }
}

- (void)close {
    [self.socket disconnectAfterReadingAndWriting];
}

#define TAG_WROTE_STUFF 10

- (void)write:(NSData *)data {
    [self.socket writeData:data withTimeout:10 tag:TAG_WROTE_STUFF];
}

- (NSData *)read {
    return [NSData new];
}

- (BOOL)isConnected {
    return self._isConnected;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self._isConnected = true;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self._isConnected = false;
}

@end
