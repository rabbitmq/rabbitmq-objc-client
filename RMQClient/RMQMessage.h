#import <Foundation/Foundation.h>
@import Mantle;

@protocol RMQMessage <NSObject>
@property (nonnull, nonatomic, copy, readonly) NSString *content;
@end

@interface RMQContentMessage : MTLModel <RMQMessage>
- (nonnull instancetype)initWithDeliveryInfo:(nonnull NSDictionary *)deliveryInfo
                                    metadata:(nonnull NSDictionary *)metadata
                                     content:(nonnull NSString *)content;
@end

@interface RMQEmptyMessage : MTLModel <RMQMessage>
@end