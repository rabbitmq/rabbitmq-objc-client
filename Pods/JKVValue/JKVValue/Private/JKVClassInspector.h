#import <Foundation/Foundation.h>

/*! The internal class JKVValue uses to for runtime introspection. All of JKVValue's core features
 *  are provided on this class.
 *
 *  For performance, this class is aggressively cached all properties.
 *
 *  This class' methods are safe to use on mutiple threads, assuming the arguments it receives
 *  are on independent threads.
 */
@interface JKVClassInspector : NSObject

// cached properties
@property (strong, nonatomic, readonly) NSArray *properties; // JKVProperty
@property (strong, nonatomic, readonly) NSArray *propertiesBackedByInstanceVariables; // JKVProperty
@property (strong, nonatomic, readonly) NSArray *weakProperties; // JKVProperty
@property (strong, nonatomic, readonly) NSArray *nonWeakProperties; // JKVProperty
@property (strong, nonatomic, readonly) NSArray *weakPropertyNames; // NSString
@property (strong, nonatomic, readonly) NSArray *nonWeakPropertyNames; // NSString

+ (void)clearInstanceCache;
+ (instancetype)inspectorForClass:(Class)aClass;
- (id)initWithClass:(Class)aClass;

- (BOOL)isObject:(id)object1 equalToObject:(id)object2 withPropertyNames:(NSArray *)propertyNames;
- (NSUInteger)hashObject:(id)object byPropertyNames:(NSArray *)propertyNames;

- (id)copyToObject:(id)targetObject
        fromObject:(id)object
            inZone:(NSZone *)zone
     propertyNames:(NSArray *)identityPropertyNames
 weakPropertyNames:(NSArray *)assignPropertyNames;


@end
