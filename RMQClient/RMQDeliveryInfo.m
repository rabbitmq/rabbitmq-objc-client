#import "RMQDeliveryInfo.h"

@interface RMQDeliveryInfo ()
@property (nonatomic, readwrite) NSString *routingKey;
@end

@implementation RMQDeliveryInfo

- (instancetype)initWithRoutingKey:(NSString *)routingKey {
    self = [super init];
    if (self) {
        self.routingKey = routingKey;
    }
    return self;
}

@end
