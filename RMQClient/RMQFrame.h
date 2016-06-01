#import "RMQValues.h"

typedef NS_ENUM(char, RMQFrameType) {
    RMQFrameTypeMethod = 1,
    RMQFrameTypeContentHeader,
    RMQFrameTypeContentBody,
    RMQFrameTypeHeartbeat = 8
};

extern NSUInteger const RMQFrameMax;
extern NSInteger const RMQEmptyFrameSize;

@interface RMQFrame : RMQValue<RMQEncodable,RMQParseable>
@property (nonnull, nonatomic, copy, readonly) NSNumber *channelNumber;
@property (nonnull, nonatomic, readonly) id<RMQPayload> payload;
- (nonnull instancetype)initWithChannelNumber:(nonnull NSNumber *)channelNumber
                                      payload:(nonnull id<RMQEncodable>)payload;
- (BOOL)isHeartbeat;
@end
