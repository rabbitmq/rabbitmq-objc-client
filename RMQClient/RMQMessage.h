#import <Foundation/Foundation.h>
#import "RMQBasicProperties.h"

@interface RMQMessage : RMQValue
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) NSString *consumerTag;
@property (nonatomic, readonly) NSNumber *deliveryTag;
@property (nonatomic, readonly) BOOL isRedelivered;
@property (nonatomic, readonly) NSString *exchangeName;
@property (nonatomic, readonly) NSString *routingKey;
@property (nonatomic, readonly) NSArray *properties;

- (instancetype)initWithContent:(NSString *)content
                    consumerTag:(NSString *)consumerTag
                    deliveryTag:(NSNumber *)deliveryTag
                    redelivered:(BOOL)isRedelivered
                   exchangeName:(NSString *)exchangeName
                     routingKey:(NSString *)routingKey
                     properties:(NSArray<RMQValue<RMQBasicValue> *> *)properties;

- (NSString *)appID;
- (NSString *)contentType;
- (NSNumber *)priority;
- (NSString *)messageType;
- (NSDictionary<NSString *, NSObject *> *)headers;
- (NSDate *)timestamp;
- (NSString *)replyTo;
- (NSString *)correlationID;
- (NSString *)messageID;

@end
