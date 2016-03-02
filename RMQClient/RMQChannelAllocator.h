#import <Foundation/Foundation.h>

@protocol RMQChannelAllocator <NSObject>
- (NSNumber *)nextID;
@end