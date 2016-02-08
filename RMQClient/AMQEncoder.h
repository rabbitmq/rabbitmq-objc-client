#import <Foundation/Foundation.h>
#import "AMQProtocolMethods.h"

@interface AMQEncoder : NSCoder

@property (nonatomic, readonly) NSMutableData *data;

- (NSData *)encodeMethod:(id<AMQMethod>)amqMethod;

- (NSData *)frameForClassID:(NSNumber *)classID
                   methodID:(NSNumber *)methodID;

@end
