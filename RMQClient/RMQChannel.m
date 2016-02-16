#import "RMQChannel.h"
#import "AMQEncoder.h"
#import "AMQDecoder.h"
#import "RMQQueue.h"

@interface RMQChannel ()
@property (nonatomic, copy, readwrite) NSNumber *channelID;
@property (weak, nonatomic, readwrite) id<RMQTransport> transport;
@property (nonatomic, readwrite) id<AMQReplyContext> replyContext;
@end

@implementation RMQChannel

- (instancetype)init:(NSNumber *)channelID
           transport:(id<RMQTransport>)transport
        replyContext:(id<AMQReplyContext>)replyContext {
    self = [super init];
    if (self) {
        self.channelID = channelID;
        self.transport = transport;
        self.replyContext = replyContext;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)send:(id<AMQMethod>)amqMethod {
    AMQEncoder *encoder = [AMQEncoder new];
    NSError *error = NULL;
    [self.transport write:[encoder encodeMethod:amqMethod
                                      channelID:self.channelID]
                    error:&error
               onComplete:^{
                   if ([self shouldAwaitServerMethod:amqMethod]) {
                       [self awaitServerMethod];
                   } else if ([self shouldSendNextRequest:amqMethod]) {
                       [self send:((id <AMQOutgoingPrecursor>)amqMethod).nextRequest];
                   }
               }];
}

- (void)awaitServerMethod {
    [self.transport readFrame:^(NSData * _Nonnull responseData) {
        if (responseData.length) {
            AMQDecoder *decoder = [[AMQDecoder alloc] initWithData:responseData];
            id parsedResponse = [decoder decode];
            if ([self shouldReply:parsedResponse]) {
                id<AMQMethod> reply = [parsedResponse replyWithContext:self.replyContext];
                [self send:reply];
            } else if ([self shouldAwaitServerMethod:parsedResponse]) {
                [self awaitServerMethod];
            }
            if ([self shouldTriggerCallback:parsedResponse]) {
                [parsedResponse didReceiveWithContext:self.transport];
            }
        }
    }];
}

- (RMQQueue *)queue:(NSString *)queueName
         autoDelete:(BOOL)shouldAutoDelete
          exclusive:(BOOL)isExclusive {
    return [[RMQQueue alloc] initWithChannel:self];
}

- (RMQExchange *)defaultExchange {
    return [RMQExchange new];
}

- (BOOL)shouldReply:(id<AMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(AMQIncomingSync)];
}

- (BOOL)shouldAwaitServerMethod:(id<AMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(AMQAwaitServerMethod)];
}

- (BOOL)shouldSendNextRequest:(id<AMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(AMQOutgoingPrecursor)];
}

- (BOOL)shouldTriggerCallback:(id<AMQMethod>)amqMethod {
    return [amqMethod conformsToProtocol:@protocol(AMQIncomingCallback)];
}
@end
