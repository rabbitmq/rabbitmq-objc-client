#import "AMQValues.h"

@interface AMQFrame : MTLModel<AMQEncoding,AMQParseable>
@property (nonnull, nonatomic, copy, readonly) NSNumber *channelNumber;
@property (nonnull, nonatomic, readonly) id<AMQPayload> payload;
- (nonnull instancetype)initWithChannelNumber:(nonnull NSNumber *)channelNumber
                                      payload:(nonnull id<AMQEncoding>)payload;
@end
