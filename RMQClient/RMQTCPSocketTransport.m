#import "RMQTCPSocketTransport.h"

@interface RMQTCPSocketTransport ()
@property (nonnull, nonatomic, readwrite) NSInputStream *readStream;
@property (nonnull, nonatomic, readwrite) NSOutputStream *writeStream;
@end

@implementation RMQTCPSocketTransport

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

- (void)close {
    [self.readStream close];
    [self.writeStream close];
}

- (void)write:(NSData *)data {
    
}

- (BOOL)isOpen {
    return [self.readStream streamStatus] == NSStreamStatusOpen &&
    [self.writeStream streamStatus] == NSStreamStatusOpen;
}

@end
