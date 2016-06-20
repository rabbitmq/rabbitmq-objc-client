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

- (NSString *)appID {
    return ((RMQBasicAppId *)[self objForClass:[RMQBasicAppId class]]).stringValue;
}

- (NSString *)contentType {
    return ((RMQBasicContentType *)[self objForClass:[RMQBasicContentType class]]).stringValue;
}

- (NSNumber *)priority {
    return @(((RMQBasicPriority *)[self objForClass:[RMQBasicPriority class]]).integerValue);
}

- (NSString *)messageType {
    return ((RMQBasicType *)[self objForClass:[RMQBasicType class]]).stringValue;
}

- (NSDictionary *)headers {
    return ((RMQBasicHeaders *)[self objForClass:[RMQBasicHeaders class]]).dictionaryValue;
}

- (NSDate *)timestamp {
    return ((RMQBasicTimestamp *)[self objForClass:[RMQBasicTimestamp class]]).dateValue;
}

- (NSString *)replyTo {
    return ((RMQBasicReplyTo *)[self objForClass:[RMQBasicReplyTo class]]).stringValue;
}

- (NSString *)correlationID {
    return ((RMQBasicCorrelationId *)[self objForClass:[RMQBasicCorrelationId class]]).stringValue;
}

- (NSString *)messageID {
    return ((RMQBasicMessageId *)[self objForClass:[RMQBasicMessageId class]]).stringValue;
}

#pragma mark - Private

- (NSDate *)objForClass:(Class)klass {
    for (id obj in self.properties) {
        if ([obj isKindOfClass:klass]) {
            return obj;
        }
    }
    return nil;
}

@end
