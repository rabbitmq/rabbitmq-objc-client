#import "RMQUnallocatedChannel.h"
#import "AMQConstants.h"

@interface RMQUnallocatedChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelNumber;
@end

@implementation RMQUnallocatedChannel

@synthesize prefetchCount;
@synthesize prefetchGlobal;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channelNumber = @(-1);
    }
    return self;
}

- (BOOL)basicConsume:(NSString *)queueName
             options:(AMQBasicConsumeOptions)options
               error:(NSError *__autoreleasing  _Nullable * _Nullable)error
            consumer:(void (^)(id<RMQMessage> _Nonnull))consumer {
    *error = [NSError errorWithDomain:RMQErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Unallocated channel"}];
    return NO;
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
- (AMQBasicQosOk *)basicQos:(NSNumber *)count
                     global:(BOOL)isGlobal
                      error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return nil;
}
- (BOOL)ack:(NSNumber *)deliveryTag options:(AMQBasicAckOptions)options error:(NSError *__autoreleasing  _Nullable *)error {
    return NO;
}
- (BOOL)ack:(NSNumber *)deliveryTag error:(NSError *__autoreleasing  _Nullable *)error {
    return [self ack:deliveryTag options:AMQBasicAckNoOptions error:error];
}
- (BOOL)reject:(NSNumber *)deliveryTag options:(AMQBasicRejectOptions)options error:(NSError *__autoreleasing  _Nullable *)error {
    return NO;
}
- (BOOL)reject:(NSNumber *)deliveryTag error:(NSError *__autoreleasing  _Nullable *)error {
    return NO;
}
@end
