#import <Foundation/Foundation.h>
#import "RMQLocalSerialQueue.h"

@interface RMQGCDSerialQueue : NSObject <RMQLocalSerialQueue>

- (instancetype)initWithName:(NSString *)name;

@end
