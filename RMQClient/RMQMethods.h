// License goes here

// This file is generated. Do not edit.
#import <Foundation/Foundation.h>
#import "RMQTable.h"

@interface RMQConnectionStart : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readonly) RMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readonly) RMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *locales;
- (nonnull instancetype)initWithVersionMajor:(nonnull RMQOctet *)versionMajor
                                versionMinor:(nonnull RMQOctet *)versionMinor
                            serverProperties:(nonnull RMQTable *)serverProperties
                                  mechanisms:(nonnull RMQLongstr *)mechanisms
                                     locales:(nonnull RMQLongstr *)locales;
@end
@interface RMQConnectionStartOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *response;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *locale;
- (nonnull instancetype)initWithClientProperties:(nonnull RMQTable *)clientProperties
                                       mechanism:(nonnull RMQShortstr *)mechanism
                                        response:(nonnull RMQLongstr *)response
                                          locale:(nonnull RMQShortstr *)locale;
@end
@interface RMQConnectionSecure : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *challenge;
- (nonnull instancetype)initWithChallenge:(nonnull RMQLongstr *)challenge;
@end
@interface RMQConnectionSecureOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *response;
- (nonnull instancetype)initWithResponse:(nonnull RMQLongstr *)response;
@end
@interface RMQConnectionTune : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) RMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) RMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull RMQShort *)channelMax
                                  frameMax:(nonnull RMQLong *)frameMax
                                 heartbeat:(nonnull RMQShort *)heartbeat;
@end
@interface RMQConnectionTuneOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) RMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) RMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull RMQShort *)channelMax
                                  frameMax:(nonnull RMQLong *)frameMax
                                 heartbeat:(nonnull RMQShort *)heartbeat;
@end
typedef NS_OPTIONS(NSUInteger, RMQConnectionOpenOptions) {
    RMQConnectionOpenNoOptions = 0,
    RMQConnectionOpenReserved2 = 1 << 0,
};

@interface RMQConnectionOpen : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
@property (nonatomic, readonly) RMQConnectionOpenOptions options;
- (nonnull instancetype)initWithVirtualHost:(nonnull RMQShortstr *)virtualHost
                                  reserved1:(nonnull RMQShortstr *)reserved1
                                    options:(RMQConnectionOpenOptions)options;
@end
@interface RMQConnectionOpenOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1;
@end
@interface RMQConnectionClose : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) RMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) RMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                  classId:(nonnull RMQShort *)classId
                                 methodId:(nonnull RMQShort *)methodId;
@end
@interface RMQConnectionCloseOk : RMQValue <RMQMethod>

@end
@interface RMQConnectionBlocked : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reason;
- (nonnull instancetype)initWithReason:(nonnull RMQShortstr *)reason;
@end
@interface RMQConnectionUnblocked : RMQValue <RMQMethod>

@end
@interface RMQChannelOpen : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1;
@end
@interface RMQChannelOpenOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLongstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQLongstr *)reserved1;
@end
typedef NS_OPTIONS(NSUInteger, RMQChannelFlowOptions) {
    RMQChannelFlowNoOptions = 0,
    RMQChannelFlowActive    = 1 << 0,
};

@interface RMQChannelFlow : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQChannelFlowOptions options;
- (nonnull instancetype)initWithOptions:(RMQChannelFlowOptions)options;
@end
typedef NS_OPTIONS(NSUInteger, RMQChannelFlowOkOptions) {
    RMQChannelFlowOkNoOptions = 0,
    RMQChannelFlowOkActive    = 1 << 0,
};

@interface RMQChannelFlowOk : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQChannelFlowOkOptions options;
- (nonnull instancetype)initWithOptions:(RMQChannelFlowOkOptions)options;
@end
@interface RMQChannelClose : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) RMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) RMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                  classId:(nonnull RMQShort *)classId
                                 methodId:(nonnull RMQShort *)methodId;
@end
@interface RMQChannelCloseOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQExchangeDeclareOptions) {
    RMQExchangeDeclareNoOptions  = 0,
    RMQExchangeDeclarePassive    = 1 << 0,
    RMQExchangeDeclareDurable    = 1 << 1,
    RMQExchangeDeclareAutoDelete = 1 << 2,
    RMQExchangeDeclareInternal   = 1 << 3,
    RMQExchangeDeclareNoWait     = 1 << 4,
};

@interface RMQExchangeDeclare : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *type;
@property (nonatomic, readonly) RMQExchangeDeclareOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                                     type:(nonnull RMQShortstr *)type
                                  options:(RMQExchangeDeclareOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end
@interface RMQExchangeDeclareOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQExchangeDeleteOptions) {
    RMQExchangeDeleteNoOptions = 0,
    RMQExchangeDeleteIfUnused  = 1 << 0,
    RMQExchangeDeleteNoWait    = 1 << 1,
};

@interface RMQExchangeDelete : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonatomic, readonly) RMQExchangeDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                                  options:(RMQExchangeDeleteOptions)options;
@end
@interface RMQExchangeDeleteOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQExchangeBindOptions) {
    RMQExchangeBindNoOptions = 0,
    RMQExchangeBindNoWait    = 1 << 0,
};

@interface RMQExchangeBind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQExchangeBindOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                              destination:(nonnull RMQShortstr *)destination
                                   source:(nonnull RMQShortstr *)source
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQExchangeBindOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end
@interface RMQExchangeBindOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQExchangeUnbindOptions) {
    RMQExchangeUnbindNoOptions = 0,
    RMQExchangeUnbindNoWait    = 1 << 0,
};

@interface RMQExchangeUnbind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQExchangeUnbindOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                              destination:(nonnull RMQShortstr *)destination
                                   source:(nonnull RMQShortstr *)source
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQExchangeUnbindOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end
@interface RMQExchangeUnbindOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQQueueDeclareOptions) {
    RMQQueueDeclareNoOptions  = 0,
    RMQQueueDeclarePassive    = 1 << 0,
    RMQQueueDeclareDurable    = 1 << 1,
    RMQQueueDeclareExclusive  = 1 << 2,
    RMQQueueDeclareAutoDelete = 1 << 3,
    RMQQueueDeclareNoWait     = 1 << 4,
};

@interface RMQQueueDeclare : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQQueueDeclareOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueueDeclareOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end
@interface RMQQueueDeclareOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
@property (nonnull, copy, nonatomic, readonly) RMQLong *consumerCount;
- (nonnull instancetype)initWithQueue:(nonnull RMQShortstr *)queue
                         messageCount:(nonnull RMQLong *)messageCount
                        consumerCount:(nonnull RMQLong *)consumerCount;
@end
typedef NS_OPTIONS(NSUInteger, RMQQueueBindOptions) {
    RMQQueueBindNoOptions = 0,
    RMQQueueBindNoWait    = 1 << 0,
};

@interface RMQQueueBind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQQueueBindOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQQueueBindOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end
@interface RMQQueueBindOk : RMQValue <RMQMethod>

@end
@interface RMQQueueUnbind : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                arguments:(nonnull RMQTable *)arguments;
@end
@interface RMQQueueUnbindOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQQueuePurgeOptions) {
    RMQQueuePurgeNoOptions = 0,
    RMQQueuePurgeNoWait    = 1 << 0,
};

@interface RMQQueuePurge : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQQueuePurgeOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueuePurgeOptions)options;
@end
@interface RMQQueuePurgeOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull RMQLong *)messageCount;
@end
typedef NS_OPTIONS(NSUInteger, RMQQueueDeleteOptions) {
    RMQQueueDeleteNoOptions = 0,
    RMQQueueDeleteIfUnused  = 1 << 0,
    RMQQueueDeleteIfEmpty   = 1 << 1,
    RMQQueueDeleteNoWait    = 1 << 2,
};

@interface RMQQueueDelete : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQQueueDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQQueueDeleteOptions)options;
@end
@interface RMQQueueDeleteOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull RMQLong *)messageCount;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicQosOptions) {
    RMQBasicQosNoOptions = 0,
    RMQBasicQosGlobal    = 1 << 0,
};

@interface RMQBasicQos : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readonly) RMQShort *prefetchCount;
@property (nonatomic, readonly) RMQBasicQosOptions options;
- (nonnull instancetype)initWithPrefetchSize:(nonnull RMQLong *)prefetchSize
                               prefetchCount:(nonnull RMQShort *)prefetchCount
                                     options:(RMQBasicQosOptions)options;
@end
@interface RMQBasicQosOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQBasicConsumeOptions) {
    RMQBasicConsumeNoOptions = 0,
    RMQBasicConsumeNoLocal   = 1 << 0,
    RMQBasicConsumeNoAck     = 1 << 1,
    RMQBasicConsumeExclusive = 1 << 2,
    RMQBasicConsumeNoWait    = 1 << 3,
};

@interface RMQBasicConsume : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
@property (nonatomic, readonly) RMQBasicConsumeOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                              consumerTag:(nonnull RMQShortstr *)consumerTag
                                  options:(RMQBasicConsumeOptions)options
                                arguments:(nonnull RMQTable *)arguments;
@end
@interface RMQBasicConsumeOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicCancelOptions) {
    RMQBasicCancelNoOptions = 0,
    RMQBasicCancelNoWait    = 1 << 0,
};

@interface RMQBasicCancel : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
@property (nonatomic, readonly) RMQBasicCancelOptions options;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag
                                    options:(RMQBasicCancelOptions)options;
@end
@interface RMQBasicCancelOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicPublishOptions) {
    RMQBasicPublishNoOptions = 0,
    RMQBasicPublishMandatory = 1 << 0,
};

@interface RMQBasicPublish : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonatomic, readonly) RMQBasicPublishOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey
                                  options:(RMQBasicPublishOptions)options;
@end
@interface RMQBasicReturn : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
- (nonnull instancetype)initWithReplyCode:(nonnull RMQShort *)replyCode
                                replyText:(nonnull RMQShortstr *)replyText
                                 exchange:(nonnull RMQShortstr *)exchange
                               routingKey:(nonnull RMQShortstr *)routingKey;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicDeliverOptions) {
    RMQBasicDeliverNoOptions   = 0,
    RMQBasicDeliverRedelivered = 1 << 0,
};

@interface RMQBasicDeliver : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicDeliverOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
- (nonnull instancetype)initWithConsumerTag:(nonnull RMQShortstr *)consumerTag
                                deliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicDeliverOptions)options
                                   exchange:(nonnull RMQShortstr *)exchange
                                 routingKey:(nonnull RMQShortstr *)routingKey;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicGetOptions) {
    RMQBasicGetNoOptions = 0,
    RMQBasicGetNoAck     = 1 << 0,
};

@interface RMQBasicGet : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *queue;
@property (nonatomic, readonly) RMQBasicGetOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShort *)reserved1
                                    queue:(nonnull RMQShortstr *)queue
                                  options:(RMQBasicGetOptions)options;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicGetOkOptions) {
    RMQBasicGetOkNoOptions   = 0,
    RMQBasicGetOkRedelivered = 1 << 0,
};

@interface RMQBasicGetOk : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicGetOkOptions options;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) RMQLong *messageCount;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicGetOkOptions)options
                                   exchange:(nonnull RMQShortstr *)exchange
                                 routingKey:(nonnull RMQShortstr *)routingKey
                               messageCount:(nonnull RMQLong *)messageCount;
@end
@interface RMQBasicGetEmpty : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull RMQShortstr *)reserved1;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicAckOptions) {
    RMQBasicAckNoOptions = 0,
    RMQBasicAckMultiple  = 1 << 0,
};

@interface RMQBasicAck : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicAckOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicAckOptions)options;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicRejectOptions) {
    RMQBasicRejectNoOptions = 0,
    RMQBasicRejectRequeue   = 1 << 0,
};

@interface RMQBasicReject : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicRejectOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicRejectOptions)options;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicRecoverAsyncOptions) {
    RMQBasicRecoverAsyncNoOptions = 0,
    RMQBasicRecoverAsyncRequeue   = 1 << 0,
};

@interface RMQBasicRecoverAsync : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQBasicRecoverAsyncOptions options;
- (nonnull instancetype)initWithOptions:(RMQBasicRecoverAsyncOptions)options;
@end
typedef NS_OPTIONS(NSUInteger, RMQBasicRecoverOptions) {
    RMQBasicRecoverNoOptions = 0,
    RMQBasicRecoverRequeue   = 1 << 0,
};

@interface RMQBasicRecover : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQBasicRecoverOptions options;
- (nonnull instancetype)initWithOptions:(RMQBasicRecoverOptions)options;
@end
@interface RMQBasicRecoverOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQBasicNackOptions) {
    RMQBasicNackNoOptions = 0,
    RMQBasicNackMultiple  = 1 << 0,
    RMQBasicNackRequeue   = 1 << 1,
};

@interface RMQBasicNack : RMQValue <RMQMethod>
@property (nonnull, copy, nonatomic, readonly) RMQLonglong *deliveryTag;
@property (nonatomic, readonly) RMQBasicNackOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull RMQLonglong *)deliveryTag
                                    options:(RMQBasicNackOptions)options;
@end
@interface RMQTxSelect : RMQValue <RMQMethod>

@end
@interface RMQTxSelectOk : RMQValue <RMQMethod>

@end
@interface RMQTxCommit : RMQValue <RMQMethod>

@end
@interface RMQTxCommitOk : RMQValue <RMQMethod>

@end
@interface RMQTxRollback : RMQValue <RMQMethod>

@end
@interface RMQTxRollbackOk : RMQValue <RMQMethod>

@end
typedef NS_OPTIONS(NSUInteger, RMQConfirmSelectOptions) {
    RMQConfirmSelectNoOptions = 0,
    RMQConfirmSelectNowait    = 1 << 0,
};

@interface RMQConfirmSelect : RMQValue <RMQMethod>
@property (nonatomic, readonly) RMQConfirmSelectOptions options;
- (nonnull instancetype)initWithOptions:(RMQConfirmSelectOptions)options;
@end
@interface RMQConfirmSelectOk : RMQValue <RMQMethod>

@end
