#import "AMQProtocolHeader.h"
#import "AMQProtocolMethods.h"

@implementation AMQProtocolHeader

- (NSData *)amqEncoded {
    char *buffer = malloc(8);
    sprintf(buffer, "AMQP%c%c%c%c", 0, 0, 9, 1);
    return [NSData dataWithBytesNoCopy:buffer length:8];
}

- (Class)expectedResponseClass {
    return [AMQProtocolConnectionStart class];
}

@end
