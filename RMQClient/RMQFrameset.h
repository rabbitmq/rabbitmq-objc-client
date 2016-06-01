#import "RMQValues.h"

@interface RMQFrameset : JKVValue<RMQEncodable>
@property (nonnull, nonatomic, copy, readonly) NSNumber *channelNumber;
@property (nonnull, nonatomic, copy, readonly) id<RMQMethod>method;
@property (nonnull, nonatomic, readonly) RMQContentHeader *contentHeader;
@property (nonnull, nonatomic, readonly) NSArray<RMQContentBody *> *contentBodies;
- (nonnull instancetype)initWithChannelNumber:(nonnull NSNumber *)channelNumber
                                       method:(nonnull id<RMQMethod>)method
                                contentHeader:(nonnull RMQContentHeader *)contentHeader
                                contentBodies:(nonnull NSArray *)contentBodies;
- (nonnull instancetype)initWithChannelNumber:(nonnull NSNumber *)channelNumber
                                       method:(nonnull id<RMQMethod>)method;
- (nonnull NSData *)contentData;
- (nonnull RMQFrameset *)addBody:(nonnull RMQContentBody *)body;
@end