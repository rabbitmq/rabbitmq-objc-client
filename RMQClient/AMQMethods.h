// This file is generated. Do not edit.
#import <Foundation/Foundation.h>
@import Mantle;
#import "AMQValues.h"

@interface AMQConnectionStart : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQOctet *versionMajor;
@property (nonnull, copy, nonatomic, readonly) AMQOctet *versionMinor;
@property (nonnull, copy, nonatomic, readonly) AMQTable *serverProperties;
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *mechanisms;
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *locales;
- (nonnull instancetype)initWithVersionMajor:(nonnull AMQOctet *)versionMajor
                                versionMinor:(nonnull AMQOctet *)versionMinor
                            serverProperties:(nonnull AMQTable *)serverProperties
                                  mechanisms:(nonnull AMQLongstr *)mechanisms
                                     locales:(nonnull AMQLongstr *)locales;
@end

@interface AMQConnectionStartOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *response;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *locale;
- (nonnull instancetype)initWithClientProperties:(nonnull AMQTable *)clientProperties
                                       mechanism:(nonnull AMQShortstr *)mechanism
                                        response:(nonnull AMQLongstr *)response
                                          locale:(nonnull AMQShortstr *)locale;
@end

@interface AMQConnectionSecure : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *challenge;
- (nonnull instancetype)initWithChallenge:(nonnull AMQLongstr *)challenge;
@end

@interface AMQConnectionSecureOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *response;
- (nonnull instancetype)initWithResponse:(nonnull AMQLongstr *)response;
@end

@interface AMQConnectionTune : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) AMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat;
@end

@interface AMQConnectionTuneOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) AMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat;
@end

typedef NS_OPTIONS(NSUInteger, AMQConnectionOpenOptions) {
    AMQConnectionOpenNoOptions = 0,
    AMQConnectionOpenReserved2 = 1 << 0,
};

@interface AMQConnectionOpen : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
@property (nonatomic, readonly) AMQConnectionOpenOptions options;
- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortstr *)virtualHost
                                  reserved1:(nonnull AMQShortstr *)reserved1
                                    options:(AMQConnectionOpenOptions)options;
@end

@interface AMQConnectionOpenOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1;
@end

@interface AMQConnectionClose : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) AMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) AMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                  classId:(nonnull AMQShort *)classId
                                 methodId:(nonnull AMQShort *)methodId;
@end

@interface AMQConnectionCloseOk : MTLModel <AMQMethod>

@end

@interface AMQConnectionBlocked : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reason;
- (nonnull instancetype)initWithReason:(nonnull AMQShortstr *)reason;
@end

@interface AMQConnectionUnblocked : MTLModel <AMQMethod>

@end

@interface AMQChannelOpen : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1;
@end

@interface AMQChannelOpenOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQLongstr *)reserved1;
@end

typedef NS_OPTIONS(NSUInteger, AMQChannelFlowOptions) {
    AMQChannelFlowNoOptions = 0,
    AMQChannelFlowActive = 1 << 0,
};

@interface AMQChannelFlow : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQChannelFlowOptions options;
- (nonnull instancetype)initWithOptions:(AMQChannelFlowOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQChannelFlowOkOptions) {
    AMQChannelFlowOkNoOptions = 0,
    AMQChannelFlowOkActive = 1 << 0,
};

@interface AMQChannelFlowOk : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQChannelFlowOkOptions options;
- (nonnull instancetype)initWithOptions:(AMQChannelFlowOkOptions)options;
@end

@interface AMQChannelClose : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) AMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) AMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                  classId:(nonnull AMQShort *)classId
                                 methodId:(nonnull AMQShort *)methodId;
@end

@interface AMQChannelCloseOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQExchangeDeclareOptions) {
    AMQExchangeDeclareNoOptions = 0,
    AMQExchangeDeclarePassive    = 1 << 0,
    AMQExchangeDeclareDurable    = 1 << 1,
    AMQExchangeDeclareAutoDelete = 1 << 2,
    AMQExchangeDeclareInternal   = 1 << 3,
    AMQExchangeDeclareNoWait     = 1 << 4,
};

@interface AMQExchangeDeclare : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *type;
@property (nonatomic, readonly) AMQExchangeDeclareOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                     type:(nonnull AMQShortstr *)type
                                  options:(AMQExchangeDeclareOptions)options
                                arguments:(nonnull AMQTable *)arguments;
@end

@interface AMQExchangeDeclareOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQExchangeDeleteOptions) {
    AMQExchangeDeleteNoOptions = 0,
    AMQExchangeDeleteIfUnused = 1 << 0,
    AMQExchangeDeleteNoWait   = 1 << 1,
};

@interface AMQExchangeDelete : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonatomic, readonly) AMQExchangeDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                  options:(AMQExchangeDeleteOptions)options;
@end

@interface AMQExchangeDeleteOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQExchangeBindOptions) {
    AMQExchangeBindNoOptions = 0,
    AMQExchangeBindNoWait = 1 << 0,
};

@interface AMQExchangeBind : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonatomic, readonly) AMQExchangeBindOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQExchangeBindOptions)options
                                arguments:(nonnull AMQTable *)arguments;
@end

@interface AMQExchangeBindOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQExchangeUnbindOptions) {
    AMQExchangeUnbindNoOptions = 0,
    AMQExchangeUnbindNoWait = 1 << 0,
};

@interface AMQExchangeUnbind : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonatomic, readonly) AMQExchangeUnbindOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQExchangeUnbindOptions)options
                                arguments:(nonnull AMQTable *)arguments;
@end

@interface AMQExchangeUnbindOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQQueueDeclareOptions) {
    AMQQueueDeclareNoOptions = 0,
    AMQQueueDeclarePassive    = 1 << 0,
    AMQQueueDeclareDurable    = 1 << 1,
    AMQQueueDeclareExclusive  = 1 << 2,
    AMQQueueDeclareAutoDelete = 1 << 3,
    AMQQueueDeclareNoWait     = 1 << 4,
};

@interface AMQQueueDeclare : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonatomic, readonly) AMQQueueDeclareOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQQueueDeclareOptions)options
                                arguments:(nonnull AMQTable *)arguments;
@end

@interface AMQQueueDeclareOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
@property (nonnull, copy, nonatomic, readonly) AMQLong *consumerCount;
- (nonnull instancetype)initWithQueue:(nonnull AMQShortstr *)queue
                         messageCount:(nonnull AMQLong *)messageCount
                        consumerCount:(nonnull AMQLong *)consumerCount;
@end

typedef NS_OPTIONS(NSUInteger, AMQQueueBindOptions) {
    AMQQueueBindNoOptions = 0,
    AMQQueueBindNoWait = 1 << 0,
};

@interface AMQQueueBind : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonatomic, readonly) AMQQueueBindOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQQueueBindOptions)options
                                arguments:(nonnull AMQTable *)arguments;
@end

@interface AMQQueueBindOk : MTLModel <AMQMethod>

@end

@interface AMQQueueUnbind : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                arguments:(nonnull AMQTable *)arguments;
@end

@interface AMQQueueUnbindOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQQueuePurgeOptions) {
    AMQQueuePurgeNoOptions = 0,
    AMQQueuePurgeNoWait = 1 << 0,
};

@interface AMQQueuePurge : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonatomic, readonly) AMQQueuePurgeOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQQueuePurgeOptions)options;
@end

@interface AMQQueuePurgeOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount;
@end

typedef NS_OPTIONS(NSUInteger, AMQQueueDeleteOptions) {
    AMQQueueDeleteNoOptions = 0,
    AMQQueueDeleteIfUnused = 1 << 0,
    AMQQueueDeleteIfEmpty  = 1 << 1,
    AMQQueueDeleteNoWait   = 1 << 2,
};

@interface AMQQueueDelete : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonatomic, readonly) AMQQueueDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQQueueDeleteOptions)options;
@end

@interface AMQQueueDeleteOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicQosOptions) {
    AMQBasicQosNoOptions = 0,
    AMQBasicQosGlobal = 1 << 0,
};

@interface AMQBasicQos : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readonly) AMQShort *prefetchCount;
@property (nonatomic, readonly) AMQBasicQosOptions options;
- (nonnull instancetype)initWithPrefetchSize:(nonnull AMQLong *)prefetchSize
                               prefetchCount:(nonnull AMQShort *)prefetchCount
                                     options:(AMQBasicQosOptions)options;
@end

@interface AMQBasicQosOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQBasicConsumeOptions) {
    AMQBasicConsumeNoOptions = 0,
    AMQBasicConsumeNoLocal   = 1 << 0,
    AMQBasicConsumeNoAck     = 1 << 1,
    AMQBasicConsumeExclusive = 1 << 2,
    AMQBasicConsumeNoWait    = 1 << 3,
};

@interface AMQBasicConsume : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
@property (nonatomic, readonly) AMQBasicConsumeOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                              consumerTag:(nonnull AMQShortstr *)consumerTag
                                  options:(AMQBasicConsumeOptions)options
                                arguments:(nonnull AMQTable *)arguments;
@end

@interface AMQBasicConsumeOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicCancelOptions) {
    AMQBasicCancelNoOptions = 0,
    AMQBasicCancelNoWait = 1 << 0,
};

@interface AMQBasicCancel : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
@property (nonatomic, readonly) AMQBasicCancelOptions options;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                    options:(AMQBasicCancelOptions)options;
@end

@interface AMQBasicCancelOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicPublishOptions) {
    AMQBasicPublishNoOptions = 0,
    AMQBasicPublishMandatory = 1 << 0,
    AMQBasicPublishImmediate = 1 << 1,
};

@interface AMQBasicPublish : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonatomic, readonly) AMQBasicPublishOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQBasicPublishOptions)options;
@end

@interface AMQBasicReturn : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicDeliverOptions) {
    AMQBasicDeliverNoOptions = 0,
    AMQBasicDeliverRedelivered = 1 << 0,
};

@interface AMQBasicDeliver : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQBasicDeliverOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                deliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicDeliverOptions)options
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicGetOptions) {
    AMQBasicGetNoOptions = 0,
    AMQBasicGetNoAck = 1 << 0,
};

@interface AMQBasicGet : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonatomic, readonly) AMQBasicGetOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQBasicGetOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicGetOkOptions) {
    AMQBasicGetOkNoOptions = 0,
    AMQBasicGetOkRedelivered = 1 << 0,
};

@interface AMQBasicGetOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQBasicGetOkOptions options;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicGetOkOptions)options
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey
                               messageCount:(nonnull AMQLong *)messageCount;
@end

@interface AMQBasicGetEmpty : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicAckOptions) {
    AMQBasicAckNoOptions = 0,
    AMQBasicAckMultiple = 1 << 0,
};

@interface AMQBasicAck : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQBasicAckOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicAckOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicRejectOptions) {
    AMQBasicRejectNoOptions = 0,
    AMQBasicRejectRequeue = 1 << 0,
};

@interface AMQBasicReject : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQBasicRejectOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicRejectOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicRecoverAsyncOptions) {
    AMQBasicRecoverAsyncNoOptions = 0,
    AMQBasicRecoverAsyncRequeue = 1 << 0,
};

@interface AMQBasicRecoverAsync : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQBasicRecoverAsyncOptions options;
- (nonnull instancetype)initWithOptions:(AMQBasicRecoverAsyncOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQBasicRecoverOptions) {
    AMQBasicRecoverNoOptions = 0,
    AMQBasicRecoverRequeue = 1 << 0,
};

@interface AMQBasicRecover : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQBasicRecoverOptions options;
- (nonnull instancetype)initWithOptions:(AMQBasicRecoverOptions)options;
@end

@interface AMQBasicRecoverOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQBasicNackOptions) {
    AMQBasicNackNoOptions = 0,
    AMQBasicNackMultiple = 1 << 0,
    AMQBasicNackRequeue  = 1 << 1,
};

@interface AMQBasicNack : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQBasicNackOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQBasicNackOptions)options;
@end

@interface AMQTxSelect : MTLModel <AMQMethod>

@end

@interface AMQTxSelectOk : MTLModel <AMQMethod>

@end

@interface AMQTxCommit : MTLModel <AMQMethod>

@end

@interface AMQTxCommitOk : MTLModel <AMQMethod>

@end

@interface AMQTxRollback : MTLModel <AMQMethod>

@end

@interface AMQTxRollbackOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQConfirmSelectOptions) {
    AMQConfirmSelectNoOptions = 0,
    AMQConfirmSelectNowait = 1 << 0,
};

@interface AMQConfirmSelect : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQConfirmSelectOptions options;
- (nonnull instancetype)initWithOptions:(AMQConfirmSelectOptions)options;
@end

@interface AMQConfirmSelectOk : MTLModel <AMQMethod>

@end

