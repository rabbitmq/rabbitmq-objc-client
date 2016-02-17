// This file is generated. Do not edit.
#import <Foundation/Foundation.h>
@import Mantle;
#import "AMQProtocolValues.h"

@interface AMQProtocolConnectionStart : MTLModel <AMQMethod>
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

@interface AMQProtocolConnectionStartOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQTable *clientProperties;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *mechanism;
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *response;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *locale;
- (nonnull instancetype)initWithClientProperties:(nonnull AMQTable *)clientProperties
                                       mechanism:(nonnull AMQShortstr *)mechanism
                                        response:(nonnull AMQLongstr *)response
                                          locale:(nonnull AMQShortstr *)locale;
@end

@interface AMQProtocolConnectionSecure : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *challenge;
- (nonnull instancetype)initWithChallenge:(nonnull AMQLongstr *)challenge;
@end

@interface AMQProtocolConnectionSecureOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *response;
- (nonnull instancetype)initWithResponse:(nonnull AMQLongstr *)response;
@end

@interface AMQProtocolConnectionTune : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) AMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat;
@end

@interface AMQProtocolConnectionTuneOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *channelMax;
@property (nonnull, copy, nonatomic, readonly) AMQLong *frameMax;
@property (nonnull, copy, nonatomic, readonly) AMQShort *heartbeat;
- (nonnull instancetype)initWithChannelMax:(nonnull AMQShort *)channelMax
                                  frameMax:(nonnull AMQLong *)frameMax
                                 heartbeat:(nonnull AMQShort *)heartbeat;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolConnectionOpenOptions) {
    AMQProtocolConnectionOpenNoOptions = 0,
    AMQProtocolConnectionOpenReserved2 = 1 << 0,
};

@interface AMQProtocolConnectionOpen : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *virtualHost;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
@property (nonatomic, readonly) AMQProtocolConnectionOpenOptions options;
- (nonnull instancetype)initWithVirtualHost:(nonnull AMQShortstr *)virtualHost
                                  reserved1:(nonnull AMQShortstr *)reserved1
                                    options:(AMQProtocolConnectionOpenOptions)options;
@end

@interface AMQProtocolConnectionOpenOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1;
@end

@interface AMQProtocolConnectionClose : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) AMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) AMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                  classId:(nonnull AMQShort *)classId
                                 methodId:(nonnull AMQShort *)methodId;
@end

@interface AMQProtocolConnectionCloseOk : MTLModel <AMQMethod>

@end

@interface AMQProtocolConnectionBlocked : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reason;
- (nonnull instancetype)initWithReason:(nonnull AMQShortstr *)reason;
@end

@interface AMQProtocolConnectionUnblocked : MTLModel <AMQMethod>

@end

@interface AMQProtocolChannelOpen : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1;
@end

@interface AMQProtocolChannelOpenOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLongstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQLongstr *)reserved1;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolChannelFlowOptions) {
    AMQProtocolChannelFlowNoOptions = 0,
    AMQProtocolChannelFlowActive = 1 << 0,
};

@interface AMQProtocolChannelFlow : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQProtocolChannelFlowOptions options;
- (nonnull instancetype)initWithOptions:(AMQProtocolChannelFlowOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolChannelFlowOkOptions) {
    AMQProtocolChannelFlowOkNoOptions = 0,
    AMQProtocolChannelFlowOkActive = 1 << 0,
};

@interface AMQProtocolChannelFlowOk : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQProtocolChannelFlowOkOptions options;
- (nonnull instancetype)initWithOptions:(AMQProtocolChannelFlowOkOptions)options;
@end

@interface AMQProtocolChannelClose : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) AMQShort *classId;
@property (nonnull, copy, nonatomic, readonly) AMQShort *methodId;
- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                  classId:(nonnull AMQShort *)classId
                                 methodId:(nonnull AMQShort *)methodId;
@end

@interface AMQProtocolChannelCloseOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolExchangeDeclareOptions) {
    AMQProtocolExchangeDeclareNoOptions = 0,
    AMQProtocolExchangeDeclarePassive    = 1 << 0,
    AMQProtocolExchangeDeclareDurable    = 1 << 1,
    AMQProtocolExchangeDeclareAutoDelete = 1 << 2,
    AMQProtocolExchangeDeclareInternal   = 1 << 3,
    AMQProtocolExchangeDeclareNoWait     = 1 << 4,
};

@interface AMQProtocolExchangeDeclare : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *type;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
@property (nonatomic, readonly) AMQProtocolExchangeDeclareOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                     type:(nonnull AMQShortstr *)type
                                arguments:(nonnull AMQTable *)arguments
                                  options:(AMQProtocolExchangeDeclareOptions)options;
@end

@interface AMQProtocolExchangeDeclareOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolExchangeDeleteOptions) {
    AMQProtocolExchangeDeleteNoOptions = 0,
    AMQProtocolExchangeDeleteIfUnused = 1 << 0,
    AMQProtocolExchangeDeleteNoWait   = 1 << 1,
};

@interface AMQProtocolExchangeDelete : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonatomic, readonly) AMQProtocolExchangeDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                                  options:(AMQProtocolExchangeDeleteOptions)options;
@end

@interface AMQProtocolExchangeDeleteOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolExchangeBindOptions) {
    AMQProtocolExchangeBindNoOptions = 0,
    AMQProtocolExchangeBindNoWait = 1 << 0,
};

@interface AMQProtocolExchangeBind : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
@property (nonatomic, readonly) AMQProtocolExchangeBindOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                arguments:(nonnull AMQTable *)arguments
                                  options:(AMQProtocolExchangeBindOptions)options;
@end

@interface AMQProtocolExchangeBindOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolExchangeUnbindOptions) {
    AMQProtocolExchangeUnbindNoOptions = 0,
    AMQProtocolExchangeUnbindNoWait = 1 << 0,
};

@interface AMQProtocolExchangeUnbind : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *destination;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *source;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
@property (nonatomic, readonly) AMQProtocolExchangeUnbindOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                              destination:(nonnull AMQShortstr *)destination
                                   source:(nonnull AMQShortstr *)source
                               routingKey:(nonnull AMQShortstr *)routingKey
                                arguments:(nonnull AMQTable *)arguments
                                  options:(AMQProtocolExchangeUnbindOptions)options;
@end

@interface AMQProtocolExchangeUnbindOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolQueueDeclareOptions) {
    AMQProtocolQueueDeclareNoOptions = 0,
    AMQProtocolQueueDeclarePassive    = 1 << 0,
    AMQProtocolQueueDeclareDurable    = 1 << 1,
    AMQProtocolQueueDeclareExclusive  = 1 << 2,
    AMQProtocolQueueDeclareAutoDelete = 1 << 3,
    AMQProtocolQueueDeclareNoWait     = 1 << 4,
};

@interface AMQProtocolQueueDeclare : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
@property (nonatomic, readonly) AMQProtocolQueueDeclareOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                arguments:(nonnull AMQTable *)arguments
                                  options:(AMQProtocolQueueDeclareOptions)options;
@end

@interface AMQProtocolQueueDeclareOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
@property (nonnull, copy, nonatomic, readonly) AMQLong *consumerCount;
- (nonnull instancetype)initWithQueue:(nonnull AMQShortstr *)queue
                         messageCount:(nonnull AMQLong *)messageCount
                        consumerCount:(nonnull AMQLong *)consumerCount;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolQueueBindOptions) {
    AMQProtocolQueueBindNoOptions = 0,
    AMQProtocolQueueBindNoWait = 1 << 0,
};

@interface AMQProtocolQueueBind : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
@property (nonatomic, readonly) AMQProtocolQueueBindOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                arguments:(nonnull AMQTable *)arguments
                                  options:(AMQProtocolQueueBindOptions)options;
@end

@interface AMQProtocolQueueBindOk : MTLModel <AMQMethod>

@end

@interface AMQProtocolQueueUnbind : MTLModel <AMQMethod>
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

@interface AMQProtocolQueueUnbindOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolQueuePurgeOptions) {
    AMQProtocolQueuePurgeNoOptions = 0,
    AMQProtocolQueuePurgeNoWait = 1 << 0,
};

@interface AMQProtocolQueuePurge : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonatomic, readonly) AMQProtocolQueuePurgeOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQProtocolQueuePurgeOptions)options;
@end

@interface AMQProtocolQueuePurgeOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolQueueDeleteOptions) {
    AMQProtocolQueueDeleteNoOptions = 0,
    AMQProtocolQueueDeleteIfUnused = 1 << 0,
    AMQProtocolQueueDeleteIfEmpty  = 1 << 1,
    AMQProtocolQueueDeleteNoWait   = 1 << 2,
};

@interface AMQProtocolQueueDelete : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonatomic, readonly) AMQProtocolQueueDeleteOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQProtocolQueueDeleteOptions)options;
@end

@interface AMQProtocolQueueDeleteOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
- (nonnull instancetype)initWithMessageCount:(nonnull AMQLong *)messageCount;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicQosOptions) {
    AMQProtocolBasicQosNoOptions = 0,
    AMQProtocolBasicQosGlobal = 1 << 0,
};

@interface AMQProtocolBasicQos : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLong *prefetchSize;
@property (nonnull, copy, nonatomic, readonly) AMQShort *prefetchCount;
@property (nonatomic, readonly) AMQProtocolBasicQosOptions options;
- (nonnull instancetype)initWithPrefetchSize:(nonnull AMQLong *)prefetchSize
                               prefetchCount:(nonnull AMQShort *)prefetchCount
                                     options:(AMQProtocolBasicQosOptions)options;
@end

@interface AMQProtocolBasicQosOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicConsumeOptions) {
    AMQProtocolBasicConsumeNoOptions = 0,
    AMQProtocolBasicConsumeNoLocal   = 1 << 0,
    AMQProtocolBasicConsumeNoAck     = 1 << 1,
    AMQProtocolBasicConsumeExclusive = 1 << 2,
    AMQProtocolBasicConsumeNoWait    = 1 << 3,
};

@interface AMQProtocolBasicConsume : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readonly) AMQTable *arguments;
@property (nonatomic, readonly) AMQProtocolBasicConsumeOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                              consumerTag:(nonnull AMQShortstr *)consumerTag
                                arguments:(nonnull AMQTable *)arguments
                                  options:(AMQProtocolBasicConsumeOptions)options;
@end

@interface AMQProtocolBasicConsumeOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicCancelOptions) {
    AMQProtocolBasicCancelNoOptions = 0,
    AMQProtocolBasicCancelNoWait = 1 << 0,
};

@interface AMQProtocolBasicCancel : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
@property (nonatomic, readonly) AMQProtocolBasicCancelOptions options;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                    options:(AMQProtocolBasicCancelOptions)options;
@end

@interface AMQProtocolBasicCancelOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicPublishOptions) {
    AMQProtocolBasicPublishNoOptions = 0,
    AMQProtocolBasicPublishMandatory = 1 << 0,
    AMQProtocolBasicPublishImmediate = 1 << 1,
};

@interface AMQProtocolBasicPublish : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonatomic, readonly) AMQProtocolBasicPublishOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey
                                  options:(AMQProtocolBasicPublishOptions)options;
@end

@interface AMQProtocolBasicReturn : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *replyCode;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *replyText;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
- (nonnull instancetype)initWithReplyCode:(nonnull AMQShort *)replyCode
                                replyText:(nonnull AMQShortstr *)replyText
                                 exchange:(nonnull AMQShortstr *)exchange
                               routingKey:(nonnull AMQShortstr *)routingKey;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicDeliverOptions) {
    AMQProtocolBasicDeliverNoOptions = 0,
    AMQProtocolBasicDeliverRedelivered = 1 << 0,
};

@interface AMQProtocolBasicDeliver : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *consumerTag;
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonatomic, readonly) AMQProtocolBasicDeliverOptions options;
- (nonnull instancetype)initWithConsumerTag:(nonnull AMQShortstr *)consumerTag
                                deliveryTag:(nonnull AMQLonglong *)deliveryTag
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey
                                    options:(AMQProtocolBasicDeliverOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicGetOptions) {
    AMQProtocolBasicGetNoOptions = 0,
    AMQProtocolBasicGetNoAck = 1 << 0,
};

@interface AMQProtocolBasicGet : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShort *reserved1;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *queue;
@property (nonatomic, readonly) AMQProtocolBasicGetOptions options;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShort *)reserved1
                                    queue:(nonnull AMQShortstr *)queue
                                  options:(AMQProtocolBasicGetOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicGetOkOptions) {
    AMQProtocolBasicGetOkNoOptions = 0,
    AMQProtocolBasicGetOkRedelivered = 1 << 0,
};

@interface AMQProtocolBasicGetOk : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *exchange;
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *routingKey;
@property (nonnull, copy, nonatomic, readonly) AMQLong *messageCount;
@property (nonatomic, readonly) AMQProtocolBasicGetOkOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                   exchange:(nonnull AMQShortstr *)exchange
                                 routingKey:(nonnull AMQShortstr *)routingKey
                               messageCount:(nonnull AMQLong *)messageCount
                                    options:(AMQProtocolBasicGetOkOptions)options;
@end

@interface AMQProtocolBasicGetEmpty : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQShortstr *reserved1;
- (nonnull instancetype)initWithReserved1:(nonnull AMQShortstr *)reserved1;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicAckOptions) {
    AMQProtocolBasicAckNoOptions = 0,
    AMQProtocolBasicAckMultiple = 1 << 0,
};

@interface AMQProtocolBasicAck : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQProtocolBasicAckOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicAckOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicRejectOptions) {
    AMQProtocolBasicRejectNoOptions = 0,
    AMQProtocolBasicRejectRequeue = 1 << 0,
};

@interface AMQProtocolBasicReject : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQProtocolBasicRejectOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicRejectOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicRecoverAsyncOptions) {
    AMQProtocolBasicRecoverAsyncNoOptions = 0,
    AMQProtocolBasicRecoverAsyncRequeue = 1 << 0,
};

@interface AMQProtocolBasicRecoverAsync : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQProtocolBasicRecoverAsyncOptions options;
- (nonnull instancetype)initWithOptions:(AMQProtocolBasicRecoverAsyncOptions)options;
@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicRecoverOptions) {
    AMQProtocolBasicRecoverNoOptions = 0,
    AMQProtocolBasicRecoverRequeue = 1 << 0,
};

@interface AMQProtocolBasicRecover : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQProtocolBasicRecoverOptions options;
- (nonnull instancetype)initWithOptions:(AMQProtocolBasicRecoverOptions)options;
@end

@interface AMQProtocolBasicRecoverOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolBasicNackOptions) {
    AMQProtocolBasicNackNoOptions = 0,
    AMQProtocolBasicNackMultiple = 1 << 0,
    AMQProtocolBasicNackRequeue  = 1 << 1,
};

@interface AMQProtocolBasicNack : MTLModel <AMQMethod>
@property (nonnull, copy, nonatomic, readonly) AMQLonglong *deliveryTag;
@property (nonatomic, readonly) AMQProtocolBasicNackOptions options;
- (nonnull instancetype)initWithDeliveryTag:(nonnull AMQLonglong *)deliveryTag
                                    options:(AMQProtocolBasicNackOptions)options;
@end

@interface AMQProtocolTxSelect : MTLModel <AMQMethod>

@end

@interface AMQProtocolTxSelectOk : MTLModel <AMQMethod>

@end

@interface AMQProtocolTxCommit : MTLModel <AMQMethod>

@end

@interface AMQProtocolTxCommitOk : MTLModel <AMQMethod>

@end

@interface AMQProtocolTxRollback : MTLModel <AMQMethod>

@end

@interface AMQProtocolTxRollbackOk : MTLModel <AMQMethod>

@end

typedef NS_OPTIONS(NSUInteger, AMQProtocolConfirmSelectOptions) {
    AMQProtocolConfirmSelectNoOptions = 0,
    AMQProtocolConfirmSelectNowait = 1 << 0,
};

@interface AMQProtocolConfirmSelect : MTLModel <AMQMethod>
@property (nonatomic, readonly) AMQProtocolConfirmSelectOptions options;
- (nonnull instancetype)initWithOptions:(AMQProtocolConfirmSelectOptions)options;
@end

@interface AMQProtocolConfirmSelectOk : MTLModel <AMQMethod>

@end

