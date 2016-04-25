#import <Foundation/Foundation.h>
@import Mantle;

@interface RMQMessage : MTLModel
@property (nonnull, nonatomic, readonly) NSString *consumerTag;
@property (nonnull, nonatomic, readonly) NSNumber *deliveryTag;
@property (nonnull, nonatomic, readonly) NSString *content;

- (nonnull instancetype)initWithConsumerTag:(nonnull NSString *)consumerTag
                                deliveryTag:(nonnull NSNumber *)deliveryTag
                                    content:(nonnull NSString *)content;
@end
