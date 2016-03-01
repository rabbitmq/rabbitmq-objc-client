#import "AMQProtocolValues.h"

@interface AMQFrame : MTLModel<AMQEncoding,AMQParseable>
@property (nonnull, nonatomic, copy, readonly) NSNumber *channelID;
@property (nonnull, nonatomic, readonly) id<AMQPayload> payload;
- (nonnull instancetype)initWithChannelID:(nonnull NSNumber *)channelID
                                  payload:(nonnull id<AMQEncoding>)payload;
@end
