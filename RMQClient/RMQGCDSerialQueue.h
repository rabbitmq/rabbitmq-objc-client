#import <Foundation/Foundation.h>
#import "RMQLocalSerialQueue.h"

@interface RMQGCDSerialQueue : NSObject <RMQLocalSerialQueue>

@property (nonatomic, readonly) NSString *name;
- (instancetype)initWithName:(NSString *)name;

@end
