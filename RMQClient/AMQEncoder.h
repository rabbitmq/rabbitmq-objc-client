#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@interface AMQEncoder : NSObject
- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod;
@end
