#import "RMQMessage.h"

@interface RMQMessage ()
@property (nonatomic, readwrite) NSString *content;
@property (nonatomic, readwrite) NSString *consumerTag;
@property (nonatomic, readwrite) NSNumber *deliveryTag;
@property (nonatomic, readwrite) BOOL isRedelivered;
@property (nonatomic, readwrite) NSString *exchangeName;
@property (nonatomic, readwrite) NSString *routingKey;
@property (nonatomic, readwrite) NSArray *properties;
@end

@implementation RMQMessage
- (instancetype)initWithContent:(NSString *)content
                    consumerTag:(NSString *)consumerTag
                    deliveryTag:(NSNumber *)deliveryTag
                    redelivered:(BOOL)isRedelivered
                   exchangeName:(NSString *)exchangeName
                     routingKey:(NSString *)routingKey
                     properties:(NSArray<RMQValue<RMQBasicValue> *> *)properties {
    self = [super init];
    if (self) {
        self.content = content;
        self.consumerTag = consumerTag;
        self.deliveryTag = deliveryTag;
        self.isRedelivered = isRedelivered;
        self.exchangeName = exchangeName;
        self.routingKey = routingKey;
        self.properties = properties;
    }
    return self;
}
@end
