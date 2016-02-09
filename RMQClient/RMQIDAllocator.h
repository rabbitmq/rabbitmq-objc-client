#import <Foundation/Foundation.h>

@protocol RMQIDAllocator <NSObject>
- (NSNumber *)nextID;
@end