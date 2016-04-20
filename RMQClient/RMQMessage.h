#import <Foundation/Foundation.h>
@import Mantle;

@protocol RMQMessage <NSObject>
@property (nonnull, nonatomic, readonly) NSString *consumerTag;
@property (nonnull, nonatomic, readonly) NSNumber *deliveryTag;
@property (nonnull, nonatomic, readonly) NSString *content;
@end

@interface RMQContentMessage : MTLModel <RMQMessage>
- (nonnull instancetype)initWithConsumerTag:(nonnull NSString *)consumerTag
                                deliveryTag:(nonnull NSNumber *)deliveryTag
                                    content:(nonnull NSString *)content;
@end
