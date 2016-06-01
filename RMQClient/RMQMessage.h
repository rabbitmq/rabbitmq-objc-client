#import <Foundation/Foundation.h>
#import "RMQBasicProperties.h"

@interface RMQMessage : RMQValue
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) NSString *consumerTag;
@property (nonatomic, readonly) NSNumber *deliveryTag;
@property (nonatomic, readonly) BOOL isRedelivered;
@property (nonatomic, readonly) NSString *exchangeName;
@property (nonatomic, readonly) NSString *routingKey;

- (instancetype)initWithContent:(NSString *)content
                    consumerTag:(NSString *)consumerTag
                    deliveryTag:(NSNumber *)deliveryTag
                    redelivered:(BOOL)isRedelivered
                   exchangeName:(NSString *)exchangeName
                     routingKey:(NSString *)routingKey
                     properties:(NSArray<RMQValue<RMQBasicValue> *> *)properties;
@end
