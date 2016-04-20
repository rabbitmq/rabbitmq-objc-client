#import "RMQHeartbeat.h"
#import "RMQValues.h"
#import "RMQFrame.h"

@implementation RMQHeartbeat

- (NSNumber *)frameTypeID { return @(RMQFrameTypeHeartbeat); }
- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[RMQOctet alloc] init:RMQFrameTypeHeartbeat].amqEncoded];
    [encoded appendData:[[RMQShort alloc] init:0].amqEncoded];
    [encoded appendData:[[RMQLong alloc] init:0].amqEncoded];
    [encoded appendData:[[RMQOctet alloc] init:0xCE].amqEncoded];
    return encoded;
}

@end
