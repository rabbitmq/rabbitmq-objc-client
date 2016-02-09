#import "RMQMessage.h"

@interface RMQMessage ()
@property (nonatomic, copy, readwrite) NSDictionary *deliveryInfo;
@property (nonatomic, copy, readwrite) NSDictionary *metadata;
@property (nonatomic, copy, readwrite) NSString *content;
@end

@implementation RMQMessage
- (instancetype)initWithDeliveryInfo:(NSDictionary *)deliveryInfo
                            metadata:(NSDictionary *)metadata
                             content:(NSString *)content {
    self = [super init];
    if (self) {
        self.deliveryInfo = deliveryInfo;
        self.metadata = metadata;
        self.content = content;
    }
    return self;
}
@end
