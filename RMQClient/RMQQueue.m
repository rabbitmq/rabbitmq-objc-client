#import "RMQQueue.h"
#import "RMQMethods.h"
#import "RMQConnection.h"
#import "RMQBasicProperties.h"
#import "RMQChannel.h"

@interface RMQQueue ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, readwrite) RMQQueueDeclareOptions options;
@property (nonatomic, readwrite) id <RMQChannel> channel;
@end

@implementation RMQQueue

- (instancetype)initWithName:(NSString *)name
                     options:(RMQQueueDeclareOptions)options
                     channel:(id<RMQChannel>)channel {
   self = [super init];
    if (self) {
        self.name = name;
        self.options = options;
        self.channel = channel;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                     channel:(id<RMQChannel>)channel {
    return [self initWithName:name options:RMQQueueDeclareNoOptions channel:channel];
}

- (void)bind:(RMQExchange *)exchange
  routingKey:(NSString *)routingKey {
    [self.channel queueBind:self.name exchange:exchange.name routingKey:routingKey];
}

- (void)bind:(RMQExchange *)exchange {
    [self bind:exchange routingKey:@""];
}

- (void)unbind:(RMQExchange *)exchange
    routingKey:(NSString *)routingKey {
    [self.channel queueUnbind:self.name exchange:exchange.name routingKey:routingKey];
}

- (void)unbind:(RMQExchange *)exchange {
    [self unbind:exchange routingKey:@""];
}

- (void)delete:(RMQQueueDeleteOptions)options {
    [self.channel queueDelete:self.name options:options];
}

- (void)delete {
    [self delete:RMQQueueDeleteNoOptions];
}

- (void)publish:(NSString *)message persistent:(BOOL)isPersistent {
    [self.channel basicPublish:message routingKey:self.name exchange:@"" persistent:isPersistent];
}

- (void)publish:(NSString *)message {
    [self publish:message persistent:NO];
}

- (void)pop:(RMQConsumerDeliveryHandler)handler {
    [self.channel basicGet:self.name
                   options:RMQBasicGetNoOptions
         completionHandler:handler];
}

- (void)subscribe:(RMQBasicConsumeOptions)options
          handler:(RMQConsumerDeliveryHandler)handler {
    [self.channel basicConsume:self.name
                       options:options
                      consumer:handler];
}

- (void)subscribe:(RMQConsumerDeliveryHandler)handler {
    return [self subscribe:RMQBasicConsumeNoAck
                   handler:handler];
}

@end
