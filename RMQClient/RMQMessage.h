#import <Foundation/Foundation.h>
@import Mantle;

@interface RMQMessage : MTLModel
- (nonnull instancetype)initWithDeliveryInfo:(nonnull NSDictionary *)deliveryInfo
                                    metadata:(nonnull NSDictionary *)metadata
                                     content:(nonnull NSString *)content;
@end
