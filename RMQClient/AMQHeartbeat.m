#import "AMQHeartbeat.h"
#import "AMQValues.h"
#import "AMQFrame.h"

@implementation AMQHeartbeat

- (NSNumber *)frameTypeID { return @(AMQFrameTypeHeartbeat); }
- (NSData *)amqEncoded {
    NSMutableData *encoded = [NSMutableData new];
    [encoded appendData:[[AMQOctet alloc] init:AMQFrameTypeHeartbeat].amqEncoded];
    [encoded appendData:[[AMQShort alloc] init:0].amqEncoded];
    [encoded appendData:[[AMQLong alloc] init:0].amqEncoded];
    [encoded appendData:[[AMQOctet alloc] init:0xCE].amqEncoded];
    return encoded;
}

@end
