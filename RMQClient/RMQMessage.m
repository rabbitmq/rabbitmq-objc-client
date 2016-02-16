#import "RMQMessage.h"

@interface RMQContentMessage ()
@property (nonatomic, copy, readwrite) NSDictionary *deliveryInfo;
@property (nonatomic, copy, readwrite) NSDictionary *metadata;
@property (nonatomic, copy, readwrite) NSString *content;
@end

@implementation RMQContentMessage
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

@interface RMQEmptyMessage ()
@property (nonnull, nonatomic, copy, readwrite) NSString *content;
@end

@implementation RMQEmptyMessage

- (instancetype)init {
    self = [super init];
    if (self) {
        self.content = @"";
    }
    return self;
}
@end