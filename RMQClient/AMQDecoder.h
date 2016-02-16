#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@interface AMQDecoder : NSCoder

@property (nonnull, nonatomic, readonly) NSNumber *channelID;
@property (nonnull, nonatomic, readonly) NSNumber *typeID;

- (nonnull instancetype)initWithData:(nonnull NSData *)data;
- (nonnull id)decode;

@end
