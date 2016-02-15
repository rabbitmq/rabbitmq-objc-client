#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@interface AMQDecoder : NSCoder

@property (nonnull, nonatomic, readonly) NSNumber *channelID;

- (nonnull instancetype)initWithData:(nonnull NSData *)data;
- (nonnull id<AMQMethod>)decodedAMQMethod;

@end
