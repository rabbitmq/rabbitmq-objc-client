#import "JKVMutableValue.h"

@interface JKVBasicValue : JKVMutableValue
@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) JKVBasicValue *nextValue;
@end
