#import "RMQValues.h"

@interface RMQTable : RMQValue<RMQFieldValue,RMQParseable>
- (nonnull instancetype)init:(nonnull NSDictionary<NSString *, RMQValue<RMQFieldValue> *> *)dictionary;
@end

