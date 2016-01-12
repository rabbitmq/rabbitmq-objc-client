#import <Foundation/Foundation.h>

@interface AMQProtocolBasicConsumeOK : NSObject
@property (nonnull, copy, nonatomic, readonly) NSString *name;
@property (nonnull, copy, nonatomic, readonly) NSString *consumerTag;
@end

@protocol AMQProtocolFrame <NSObject>
@end

@interface AMQProtocolMethodFrame : NSObject<AMQProtocolFrame>

- (nonnull instancetype)initWithPayload:(nonnull NSData *)payload
                                channel:(nonnull NSNumber *)channel;
- (nonnull NSData *)encode;

@end

@protocol AMQProtocolMethod <NSObject>

+ (nonnull instancetype)decode:(nonnull NSData *)data;

@end

@interface AMQProtocolConnectionClose : NSObject<AMQProtocolMethod>

@property (nonnull, copy, nonatomic, readonly) NSNumber *replyCode;
@property (nonnull, copy, nonatomic, readonly) NSString *replyText;
@property (nonnull, copy, nonatomic, readonly) NSNumber *classID;
@property (nonnull, copy, nonatomic, readonly) NSNumber *methodID;

+ (nonnull AMQProtocolMethodFrame *)encode:(nonnull NSNumber *)replyCode
                                 replyText:(nonnull NSString *)replyText
                                   classID:(nonnull NSNumber *)classID
                                  methodID:(nonnull NSNumber *)methodID;

@end