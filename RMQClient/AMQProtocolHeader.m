#import "AMQProtocolHeader.h"
#import "AMQProtocolMethods.h"

@implementation AMQProtocolHeader

- (NSData *)amqEncoded {
    char *buffer = malloc(8);
    memcpy(buffer, "AMQP", strlen("AMQP"));
    buffer[4] = 0;
    buffer[5] = 0;
    buffer[6] = 9;
    buffer[7] = 1;
    return [NSData dataWithBytesNoCopy:buffer length:8];
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionStart class];
}

@end
