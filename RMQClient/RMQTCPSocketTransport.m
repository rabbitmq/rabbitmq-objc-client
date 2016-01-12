#import "RMQTCPSocketTransport.h"

@interface RMQTCPSocketTransport ()
@property (nonnull, nonatomic, readwrite) NSInputStream *readStream;
@property (nonnull, nonatomic, readwrite) NSOutputStream *writeStream;
@property (nonnull, nonatomic, readwrite) NSString *host;
@property (nonnull, nonatomic, readwrite) NSNumber *port;
@end

@implementation RMQTCPSocketTransport

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port {
    self = [super init];
    if (self) {
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
    CFReadStreamRef read;
    CFWriteStreamRef write;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 5672, &read, &write);
    self.readStream = (__bridge_transfer NSInputStream *)read;
    self.writeStream = (__bridge_transfer NSOutputStream *)write;
    [self.readStream setDelegate:self];
    [self.writeStream setDelegate:self];
    [self.readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.readStream open];
    [self.writeStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
}

- (void)close {
    [self.readStream close];
    [self.writeStream close];
}

- (void)write:(NSData *)data {
}

- (NSData *)read {
    return [NSData new];
}

- (BOOL)isOpen {
    return self.readStream.streamStatus == NSStreamStatusOpen &&
    self.writeStream.streamStatus == NSStreamStatusOpen;
}

@end
