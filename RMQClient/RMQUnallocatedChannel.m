#import "RMQUnallocatedChannel.h"
#import "AMQConstants.h"
#import "RMQConnectionDelegate.h"

@interface RMQUnallocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@property (nonatomic, readwrite) id<RMQConnectionDelegate> delegate;
@end

@implementation RMQUnallocatedChannel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channelNumber = @(-1);
    }
    return self;
}

- (void)activateWithDelegate:(id<RMQConnectionDelegate>)delegate {
    self.delegate = delegate;
}
- (void)open {}

- (void)basicConsume:(NSString *)queueName
             options:(AMQBasicConsumeOptions)options
            consumer:(void (^)(id<RMQMessage> _Nonnull))consumer {
    NSError *error = [NSError errorWithDomain:RMQErrorDomain code:RMQChannelErrorUnallocated userInfo:@{NSLocalizedDescriptionKey: @"Unallocated channel"}];
    [self.delegate channel:self error:error];
}

- (void)basicPublish:(NSString *)message routingKey:(NSString *)routingKey exchange:(NSString *)exchange {
}

- (void)basicGet:(NSString *)queue options:(AMQBasicGetOptions)options completionHandler:(void (^)(id<RMQMessage> _Nonnull))completionHandler {
}

- (RMQExchange *)defaultExchange {
    return nil;
}
- (RMQQueue *)queue:(NSString *)queueName options:(AMQQueueDeclareOptions)options {
    return nil;
}
- (RMQQueue *)queue:(NSString *)queueName {
    return nil;
}
- (AMQQueueDeclareOk *)queueDeclare:(NSString *)queueName
                            options:(AMQQueueDeclareOptions)options {
    return nil;
}
- (void)handleFrameset:(AMQFrameset *)frameset {
}
- (void)basicQos:(NSNumber *)count
          global:(BOOL)isGlobal {
}
- (void)ack:(NSNumber *)deliveryTag options:(AMQBasicAckOptions)options {
}
- (void)ack:(NSNumber *)deliveryTag {
}
- (void)reject:(NSNumber *)deliveryTag options:(AMQBasicRejectOptions)options {
}
- (void)reject:(NSNumber *)deliveryTag {
}
- (void)nack:(NSNumber *)deliveryTag options:(AMQBasicNackOptions)options {
}
- (void)nack:(NSNumber *)deliveryTag {
}
@end
