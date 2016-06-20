#import <Foundation/Foundation.h>
#import "RMQBasicProperties.h"

@interface RMQBasicProperties (MergeDefaults)
+ (NSArray *)mergeProperties:(NSArray *)properties
                withDefaults:(NSArray *)defaultProperties;
@end
