#import "RMQBasicProperties+MergeDefaults.h"

@implementation RMQBasicProperties (MergeDefaults)

+ (NSArray *)mergeProperties:(NSArray *)properties
                withDefaults:(NSArray *)defaultProperties {
    NSMutableSet *defaultClassesRequired = [NSMutableSet new];
    for (RMQValue<RMQBasicValue> *property in defaultProperties) {
        [defaultClassesRequired addObject:[property class]];
    }
    NSMutableSet *parameterClasses = [NSMutableSet new];
    for (RMQValue<RMQBasicValue> *property in properties) {
        [parameterClasses addObject:[property class]];
    }
    [defaultClassesRequired minusSet:parameterClasses];

    NSMutableArray *mergedProperties = [properties mutableCopy];
    for (RMQValue<RMQBasicValue> *defaultProperty in RMQBasicProperties.defaultProperties) {
        if ([defaultClassesRequired containsObject:[defaultProperty class]]) {
            [mergedProperties addObject:defaultProperty];
        }
    }
    return mergedProperties;
}

@end
