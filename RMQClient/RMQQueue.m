#import "RMQQueue.h"

@implementation RMQQueue

- (RMQQueue *)publish:(NSString *)message {
    return self;
}

- (RMQMessage *)pop {
    return [[RMQMessage alloc] initWithDeliveryInfo:@{@"consumer_tag": @"foo"}
                                           metadata:@{@"foo": @"bar"}
                                            content:@"Hello!"];
}

@end
