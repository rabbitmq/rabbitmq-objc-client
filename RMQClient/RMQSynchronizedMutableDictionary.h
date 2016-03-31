#import <Foundation/Foundation.h>

@interface RMQSynchronizedMutableDictionary : NSObject
- (id)objectForKeyedSubscript:(NSNumber *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSNumber *)key;
- (void)removeObjectForKey:(NSNumber *)key;
@end
