#import <Mantle/Mantle.h>

@interface RMQDeliveryInfo : MTLModel

@property (nonatomic, readonly) NSString *routingKey;

- (instancetype)initWithRoutingKey:(NSString *)routingKey;

@end
