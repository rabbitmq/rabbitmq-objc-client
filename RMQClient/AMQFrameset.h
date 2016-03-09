#import "AMQValues.h"

@interface AMQFrameset : MTLModel<AMQEncoding>
@property (nonnull, nonatomic, copy, readonly) NSNumber *channelNumber;
@property (nonnull, nonatomic, copy, readonly) id<AMQMethod>method;
@property (nonnull, nonatomic, readonly) AMQContentHeader *contentHeader;
@property (nonnull, nonatomic, readonly) NSArray<AMQContentBody *> *contentBodies;
- (nonnull instancetype)initWithChannelNumber:(nonnull NSNumber *)channelNumber
                                       method:(nonnull id<AMQMethod>)method
                                contentHeader:(nonnull AMQContentHeader *)contentHeader
                                contentBodies:(nonnull NSArray *)contentBodies;
- (nonnull instancetype)initWithChannelNumber:(nonnull NSNumber *)channelNumber
                                       method:(nonnull id<AMQMethod>)method;
- (nonnull NSData *)contentData;
@end