#import <Foundation/Foundation.h>

@interface RMQSynchronizedMutableDictionary : NSObject
@property (nonatomic, readonly) NSUInteger count;
- (nullable id)objectForKeyedSubscript:(nonnull id)key;
- (void)setObject:(nonnull id)obj forKeyedSubscript:(nonnull id)key;
- (void)removeObjectForKey:(nonnull id)key;
@end
