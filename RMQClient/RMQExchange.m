#import "RMQExchange.h"
#import "RMQChannel.h"
#import "RMQBasicProperties.h"

@interface RMQExchange ()
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) RMQExchangeDeclareOptions options;
@property (nonatomic, readwrite) id<RMQChannel> channel;
@end

@implementation RMQExchange

- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                     options:(RMQExchangeDeclareOptions)options
                     channel:(id<RMQChannel>)channel {
    self = [super init];
    if (self) {
        self.name = name;
        self.type = type;
        self.options = options;
        self.channel = channel;
    }
    return self;
}

- (void)bind:(RMQExchange *)source
  routingKey:(NSString *)routingKey {
    [self.channel exchangeBind:source.name
                   destination:self.name
                    routingKey:routingKey];
}

- (void)bind:(RMQExchange *)source {
    [self bind:source routingKey:@""];
}

- (void)unbind:(RMQExchange *)source
    routingKey:(NSString *)routingKey {
    [self.channel exchangeUnbind:source.name
                     destination:self.name
                      routingKey:routingKey];
}

- (void)unbind:(RMQExchange *)source {
    [self unbind:source routingKey:@""];
}

- (void)delete:(RMQExchangeDeleteOptions)options {
    [self.channel exchangeDelete:self.name options:options];
}

- (void)delete {
    [self delete:RMQExchangeDeleteNoOptions];
}

- (void)publish:(NSString *)message
     routingKey:(NSString *)routingKey
     properties:(NSArray<RMQValue<RMQBasicValue> *> *)properties
        options:(RMQBasicPublishOptions)options {
    [self.channel basicPublish:message
                    routingKey:routingKey
                      exchange:self.name
                    properties:properties
                       options:options];
}

- (void)publish:(NSString *)message
     routingKey:(NSString *)key
     persistent:(BOOL)isPersistent
        options:(RMQBasicPublishOptions)options {
    NSMutableArray *properties = [RMQBasicProperties.defaultProperties mutableCopy];
    if (isPersistent) {
        properties[1] = [[RMQBasicDeliveryMode alloc] init:2];
    }
    [self.channel basicPublish:message
                    routingKey:key
                      exchange:self.name
                    properties:properties
                       options:options];
}

- (void)publish:(NSString *)message
     routingKey:(NSString *)key
     persistent:(BOOL)isPersistent {
    [self publish:message
       routingKey:key
       persistent:isPersistent
          options:RMQBasicPublishNoOptions];
}

- (void)publish:(NSString *)message
     routingKey:(NSString *)key {
    [self publish:message
       routingKey:key
       persistent:NO];
}

- (void)publish:(NSString *)message {
    [self publish:message
       routingKey:@""];
}

@end
