#import "AMQProtocolHeader.h"
#import "AMQProtocolMethods.h"

@implementation AMQProtocolHeader

- (NSData *)amqEncoded {
    char *buffer = malloc(8);
    memcpy(buffer, "AMQP", strlen("AMQP"));
    buffer[4] = 0x00;
    buffer[5] = 0x00;
    buffer[6] = 0x09;
    buffer[7] = 0x01;
    return [NSData dataWithBytesNoCopy:buffer length:8];
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionStart class];
}

@end
