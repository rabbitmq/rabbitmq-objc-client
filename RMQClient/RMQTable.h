#import "RMQValues.h"

@interface RMQTable : RMQValue<RMQFieldValue,RMQParseable>
@property (nonnull, nonatomic, readonly) NSDictionary *dictionaryValue;
- (nonnull instancetype)init:(nonnull NSDictionary<NSString *, RMQValue<RMQFieldValue> *> *)dictionary;
@end

