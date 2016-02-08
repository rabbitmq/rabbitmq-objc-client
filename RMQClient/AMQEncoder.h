#import <Foundation/Foundation.h>
#import "AMQProtocolMethods.h"

@interface AMQEncoder : NSCoder

@property (nonatomic, readonly) NSMutableData *data;

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod;

@end
