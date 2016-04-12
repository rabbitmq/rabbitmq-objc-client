#import "RMQQueue.h"
#import "AMQMethods.h"
#import "RMQConnection.h"
#import "AMQBasicProperties.h"
#import "AMQConstants.h"
#import "RMQChannel.h"

@interface RMQQueue ()
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, readwrite) AMQQueueDeclareOptions options;
@property (nonatomic, readwrite) id <RMQChannel> channel;
@property (weak, nonatomic, readwrite) id <RMQSender> sender;
@end

@implementation RMQQueue

- (instancetype)initWithName:(NSString *)name
                     options:(AMQQueueDeclareOptions)options
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
    return [self initWithName:name options:AMQQueueDeclareNoOptions channel:channel sender:sender];
}

- (RMQQueue *)publish:(NSString *)message {
    [self.channel basicPublish:message routingKey:self.name exchange:@""];
    return self;
}

- (void)pop:(void (^)(id<RMQMessage> _Nonnull))handler {
    [self.channel basicGet:self.name
                   options:AMQBasicGetNoOptions
         completionHandler:handler];
}

- (void)subscribe:(AMQBasicConsumeOptions)options
          handler:(void (^)(id<RMQMessage> _Nonnull))handler {
    [self.channel basicConsume:self.name
                       options:options
                      consumer:handler];
}

- (void)subscribe:(void (^)(id<RMQMessage> _Nonnull))handler {
    return [self subscribe:AMQBasicConsumeNoAck
                   handler:handler];
}

@end
