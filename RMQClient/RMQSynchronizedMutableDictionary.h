#import <Foundation/Foundation.h>

@interface RMQSynchronizedMutableDictionary : NSObject
@property (nonatomic, readonly) NSUInteger count;
- (id)objectForKeyedSubscript:(NSNumber *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSNumber *)key;
- (void)removeObjectForKey:(NSNumber *)key;
@end
