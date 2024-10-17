#import <Foundation/Foundation.h>

/*! JKVFactory provides a convinent way to generate populated value objects.
 *  Although there is no explicit binding to JKVValue, these factories assume
 *  an -[init] method for modification.
 *
 *  While JKVFactory provides non-zero default values, it is recommended to
 *  inherit or build factory instances to customize the default values for
 *  each class you want a factory.
 *
 *  Subclasses of JKVFactory should override the -[init] method and call one
 *  of the other init methods provided by this class to customize the factory.
 */
@interface JKVFactory : NSObject

/*! The class that this factory will produce instances of.
 */
@property (strong, nonatomic) Class productClass;

/*! A dictionary of properties names to values. This allows you to specify
 *  different default values when generating an object.
 *
 *  All values should be boxed. The behavior of KVC will convert to the
 *  productClass' to their correct native types.
 */
@property (copy, nonatomic) NSDictionary *properties;

/*! Builds the object the factory is configured to create.
 *  Only works for subclasses of JKVFactory that override -[init].
 *
 *  Shorthand for [[MyFactory new] object].
 *
 *  @returns a new instance of `productClass`
 */
+ (id)buildObject;

/*! Builds an object the factory is configured to create with properties
 *  to override.
 *  Only works for subclasses of JKVFactory that overide -[init].
 *
 *  Shorthand for [[MyFactory new] objectWithProperties:properties].
 *
 *  @returns a new instance of `productClass`
 */
+ (id)buildObjectWithProperties:(NSDictionary *)properties;

/*! Creates a new factory instance that can produce the object of the given class.
 *
 *  @param aClass The class of objects for the factory instance to produce.
 *  @returns a new factory instance for the given class.
 */
+ (instancetype)factoryForClass:(Class)aClass;

/*! Creates a new factory instance that can produce the object of the given class.
 *
 *  @param aClass The class of objects for the factory instance to produce.
 *  @returns a new factory instance for the given class.
 */
- (id)initWithClass:(Class)aClass;

/*! Creates a new factory instance that can produce the object of the given class.
 *
 *  @param aClass The class of objects for the factory instance to produce.
 *  @param properties A mapping of property names to values that will be set on the object when built. If properties are missing, a non-zero value is given to that property.
 *  @returns a new factory instance for the given class.
 */
- (id)initWithClass:(Class)aClass properties:(NSDictionary *)properties;

/*! Creates a new factory instance with a dictionary of properties to override.
 *
 *  @param properties A mapping of property names to values that will be set on the object when built. If properties are missing, the values are what the current factory would produce.
 *  @returns a new factory instance for the given class with customized properties
 */
- (instancetype)factoryWithProperties:(NSDictionary *)properties;

/*! Creates a new instance of productClass with the given property names to values to
 *  set on the produced object.
 *
 *  If properties a missing from the dictionary, the factory's default values are used.
 *
 *  @param properties The dictionary of property names to values to set on the object.  If properties a missing from the dictionary, the factory's default values are used.
 *  @returns A new instance of productClass of the current factory.
 */
- (id)objectWithProperties:(NSDictionary *)properties;

/*! Creates a new instance of productClass with the given property names to values to
 *  set on the produced object.
 *
 *  All properties are based on the default values of the factory.
 *
 *  @returns A new instance of productClass of the current factory.
 */
- (id)object;

@end
