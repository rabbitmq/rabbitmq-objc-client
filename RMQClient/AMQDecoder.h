#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@interface AMQDecoder : NSCoder

- (nonnull instancetype)initWithData:(nonnull NSData *)data;
- (nonnull id<AMQMethod>)decodedAMQMethod;

@end
