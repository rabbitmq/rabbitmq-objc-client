#import <Foundation/Foundation.h>

/*! JKVValue represents an Immutable Value Object class that should be subclassed to use.
 *
 *  JKVValue subclasses will introspect all its properties for various NSObject features.
 *  The following interfaces are supported when inheriting from JKVValue:
 *
 *  - NSSecureCoding (thus, NSCoding)
 *  - NSMutableCopying
 *  - NSCopying
 *
 *  This implementation assumes immutability. This means -[JKVValue copy] returns the same
 *  instance.
 *
 *  If you want a mutable variant, inherit from JKVMutableValue.
 */
@interface JKVValue : NSObject <NSMutableCopying, NSCopying, NSSecureCoding>

/*! Returns the difference between this value object an the given object.
 *
 *  This is a higher-order function to -[isEqual:] its results are similar to the
 *  behavior for equality. Unlike -[isEqual:], this method is NOT recursive.
 *
 *  The dictionary maps fields to arrays for all differing properties. Each array contains
 *  exactly two elements: the value of the field for self and the value of the field
 *  for the other object.
 *
 *  Classes are also checked, objects that differ in classes will only have a
 *  "class" key with an array of @[[self class], [otherValueObject class]];
 *
 *  @param otherValueObject The other value object to diff against.
 *
 */
- (NSDictionary *)differenceToObject:(id)otherValueObject;

/*! Override this method to return YES to indicate that this subclass is
 *  mutable. This changes the behavior of how NSCopying protocol works
 *  from returning itself to copying all properties.
 *
 *  The default returns NO. The JKVMutableValue subclass returns YES.
 */
- (BOOL)JKV_isMutable;

/*! Override this method to return the class to instanciate when using
 *  the NSCopying protocol. This is useful for when you want a mutable
 *  class to return an immutable class when -[copy] is called.
 *
 *  For example, you would override this if you wanted MyArray class to
 *  use MyMutableArray.
 *
 *  It's not advisable to override this unless you subclass JKVMutableValue.
 *
 *  @returns The immutable version of this class. The default returns the current class.
 */
- (Class)JKV_immutableClass;

/*! The reverse of -[JKV_immutableClass]. Override this method to return
 *  the class to instanciate when using the NSMutableCopying protocol.
 *  This is useful for when you want an immutable class to return a
 *  mutable class when -[mutableCopy] is called.
 *
 *  For example, you would override this if you wanted MyMutableArray
 *  class to use MyArray.
 *
 *  @returns The mutable version of this class if available. The default returns the current class.
 */
- (Class)JKV_mutableClass;

/*! For subclasses to override to specify which properties are used for equality and hashing.
 *
 *  To increase performance. Each object will call this only once and memoize its results afterwards.
 */
- (NSArray *)JKV_propertyNamesForIdentity;

/*! For subclasses to override which weak properties to check for assignment and do weak encoding.
 *
 *  To increase performance. Each object will call this only once and memoize its results afterwards.
 */
- (NSArray *)JKV_propertyNamesToAssignCopy;

@end
