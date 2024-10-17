#import "JKVValueImpl.h"

/*! JKVMutableValue represents an Immutable Value Object class that should be subclassed to use.
 *
 *  JKVMutableValue subclasses will introspect all its properties for various NSObject features.
 *  The following interfaces are supported when inheriting from JKVValue:
 *
 *  - NSSecureCoding (thus, NSCoding)
 *  - NSMutableCopying
 *  - NSCopying
 *
 * JKVMutableValue assumes mutability. Using -[copy] should return an immutable variant.
 * if available.
 *
 *  If you want a immutable variant, inherit from JKVValue.
 */
@interface JKVMutableValue : JKVValue

@end
