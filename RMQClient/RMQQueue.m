#import "RMQQueue.h"
#import "RMQMethods.h"
#import "RMQConnection.h"
#import "RMQBasicProperties.h"
#import "RMQConstants.h"
#import "RMQChannel.h"

@interface RMQQueue ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, readwrite) RMQQueueDeclareOptions options;
@property (nonatomic, readwrite) id <RMQChannel> channel;
@property (weak, nonatomic, readwrite) id <RMQSender> sender;
@end

@implementation RMQQueue

- (instancetype)initWithName:(NSString *)name
                     options:(RMQQueueDeclareOptions)options
                     channel:(id<RMQChannel>)channel
                      sender:(id<RMQSender>)sender {
   self = [super init];
    if (self) {
        self.name = name;
        self.options = options;
        self.channel = channel;
        self.sender = sender;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                     channel:(id<RMQChannel>)channel
                      sender:(id<RMQSender>)sender {
    return [self initWithName:name options:RMQQueueDeclareNoOptions channel:channel sender:sender];
}

- (void)bind:(RMQExchange *)exchange
  routingKey:(nonnull NSString *)routingKey {
    [self.channel queueBind:self.name exchange:exchange.name routingKey:routingKey];
}

- (void)bind:(RMQExchange *)exchange {
    [self bind:exchange routingKey:@""];
}

- (void)publish:(NSString *)message persistent:(BOOL)isPersistent {
    [self.channel basicPublish:message routingKey:self.name exchange:@"" persistent:isPersistent];
}

- (void)publish:(NSString *)message {
    [self publish:message persistent:NO];
}

- (void)pop:(void (^)(RMQMessage * _Nonnull))handler {
    [self.channel basicGet:self.name
                   options:RMQBasicGetNoOptions
         completionHandler:handler];
}

- (void)subscribe:(RMQBasicConsumeOptions)options
          handler:(void (^)(RMQMessage * _Nonnull))handler {
    [self.channel basicConsume:self.name
                       options:options
                      consumer:handler];
}

- (void)subscribe:(void (^)(RMQMessage * _Nonnull))handler {
    return [self subscribe:RMQBasicConsumeNoAck
                   handler:handler];
}

@end
