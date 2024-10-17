#import "JKVClassInspector.h"
#import "JKVProperty.h"
#import <objc/runtime.h>


@interface JKVClassInspector ()

@property (strong, atomic) Class aClass;
@property (strong, nonatomic, readwrite) NSArray *properties;
@property (strong, nonatomic, readwrite) NSArray *propertiesBackedByInstanceVariables;
@property (strong, nonatomic, readwrite) NSArray *weakProperties;
@property (strong, nonatomic, readwrite) NSArray *nonWeakProperties;
@property (strong, nonatomic, readwrite) NSArray *weakPropertyNames;
@property (strong, nonatomic, readwrite) NSArray *nonWeakPropertyNames;

@end


@implementation JKVClassInspector

static NSMutableDictionary *inspectors__;

+ (void)clearInstanceCache
{
    inspectors__ = [NSMutableDictionary new];
}

+ (void)initialize
{
    [super initialize];
    [self clearInstanceCache];
}

+ (instancetype)inspectorForClass:(Class)aClass
{
    NSString *key = NSStringFromClass(aClass);
    @synchronized (inspectors__) {
        JKVClassInspector *instance = [inspectors__ objectForKey:key];
        if (!instance) {
            instance = [[self alloc] initWithClass:aClass];
            [inspectors__ setObject:instance forKey:key];
        }
        return instance;
    }
}

- (id)initWithClass:(Class)aClass
{
    if (self = [super init]) {
        self.aClass = aClass;
    }
    return self;
}

#pragma mark - Private

- (BOOL)isObject:(id)object1 equalToObject:(id)object2 byPropertyNames:(NSArray *)propertyNames
{
    for (NSString *name in propertyNames) {
        id value = [object1 valueForKey:name];
        id otherValue = [object2 valueForKey:name];
        if (value != otherValue && ![value isEqual:otherValue]){
            return NO;
        }
    }
    return YES;
}

- (NSUInteger)hashObject:(id)object byPropertyNames:(NSArray *)propertyNames visitedObjects:(NSArray *)objects
{
    // http://stackoverflow.com/questions/254281/best-practices-for-overriding-isequal-and-hash
    NSUInteger prime = 31;
    NSUInteger result = 1;
    for (NSString *propertyName in propertyNames){
        result = prime * result + [[object valueForKey:propertyName] hash];
    }
    return result;
}

#pragma mark - Public

- (BOOL)isObject:(id)object1 equalToObject:(id)object2 withPropertyNames:(NSArray *)propertyNames
{
    if (object1 == object2) {
        return YES;
    }

    Class class1 = [object1 class];
    Class class2 = [object2 class];

    if (![class1 isSubclassOfClass:class2] && ![class2 isSubclassOfClass:class1]) {
        return NO;
    }

    return [self isObject:object1 equalToObject:object2 byPropertyNames:propertyNames];
}

- (NSUInteger)hashObject:(id)object byPropertyNames:(NSArray *)propertyNames
{
    // http://stackoverflow.com/questions/254281/best-practices-for-overriding-isequal-and-hash
    NSUInteger prime = 31;
    NSUInteger result = 1;
    for (NSString *propertyName in propertyNames){
        result = prime * result + [[object valueForKey:propertyName] hash];
    }
    return result;
}

- (id)copyToObject:(id)targetObject
        fromObject:(id)object
            inZone:(NSZone *)zone
     propertyNames:(NSArray *)identityPropertyNames
 weakPropertyNames:(NSArray *)assignPropertyNames
{
    for (NSString *name in identityPropertyNames) {
        id value = [object valueForKey:name];
        if ([value isKindOfClass:[NSArray class]]) {
            value = [[NSMutableArray alloc] initWithArray:value copyItems:YES];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            value = [[NSMutableDictionary alloc] initWithDictionary:value copyItems:YES];
        } else if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            value = [value mutableCopyWithZone:zone];
        }
        [targetObject setValue:value forKey:name];
    }
    for (NSString *name in assignPropertyNames) {
        [targetObject setValue:[object valueForKey:name] forKey:name];
    }

    return targetObject;
}

#pragma mark - Properties

- (NSArray *)nonWeakProperties
{
    @synchronized (self) {
        if (!_nonWeakProperties) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isWeak = NO"];
            _nonWeakProperties = [self.propertiesBackedByInstanceVariables filteredArrayUsingPredicate:predicate];
        }
        return _nonWeakProperties;
    }
}

- (NSArray *)weakProperties
{
    @synchronized (self) {
        if (!_weakProperties) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isWeak = YES"];
            _weakProperties = [self.propertiesBackedByInstanceVariables filteredArrayUsingPredicate:predicate];
        }
        return _weakProperties;
    }
}

- (NSArray *)properties
{
    @synchronized (self) {
        if (!_properties) {
            NSMutableArray *properties = [NSMutableArray new];
            unsigned int numProperties = 0;
            objc_property_t *objc_properties = class_copyPropertyList(self.aClass, &numProperties);
            for (NSUInteger i=0; i<numProperties; i++) {
                objc_property_t objc_property = objc_properties[i];

                unsigned int numAttributes = 0;
                objc_property_attribute_t *objc_attributes = property_copyAttributeList(objc_property, &numAttributes);
                NSMutableDictionary *attributesDict = [NSMutableDictionary new];
                for (NSUInteger j=0; j<numAttributes; j++) {
                    objc_property_attribute_t attribute = objc_attributes[j];
                    NSString *key = [NSString stringWithCString:attribute.name encoding:NSUTF8StringEncoding];
                    NSString *value = [NSString stringWithCString:attribute.value encoding:NSUTF8StringEncoding];
                    attributesDict[key] = value;
                }
                free(objc_attributes);

                NSString *propertyName = [NSString stringWithUTF8String:property_getName(objc_property)];

                [properties addObject:[[JKVProperty alloc] initWithName:propertyName
                                                             attributes:attributesDict]];
            }
            free(objc_properties);
            _properties = properties;
        }
        return _properties;
    }
}

- (NSArray *)_propertiesBackedByInstanceVariables
{
    NSArray *properties = [self properties];
    NSMutableArray *filteredProperties = [NSMutableArray arrayWithCapacity:properties.count];
    for (JKVProperty *property in properties) {
        if (property.ivarName.length > 0) {
            [filteredProperties addObject:property];
        }
    }
    return filteredProperties;
}

- (NSArray *)propertiesBackedByInstanceVariables
{
    @synchronized (self) {
        if (!_propertiesBackedByInstanceVariables) {
            NSArray *classProperties = [self _propertiesBackedByInstanceVariables];
            NSSet *classPropertyNames = [NSSet setWithArray:[classProperties valueForKey:@"name"]];
            NSMutableArray *properties = [NSMutableArray new];
            Class parentClass = class_getSuperclass(self.aClass);
            if (parentClass && parentClass != [NSObject class]) {
                NSArray *parentClassProperties = [[JKVClassInspector inspectorForClass:parentClass] _propertiesBackedByInstanceVariables];
                for (JKVProperty *property in parentClassProperties) {
                    if (![classPropertyNames containsObject:property.name]) {
                        [properties addObject:property];
                    }
                }
            }
            [properties addObjectsFromArray:classProperties];
            [properties removeObjectsInArray:[[JKVClassInspector inspectorForClass:[NSObject class]] _propertiesBackedByInstanceVariables]];
            _propertiesBackedByInstanceVariables = properties;
        }
        return _propertiesBackedByInstanceVariables;
    }
}

- (NSArray *)weakPropertyNames
{
    @synchronized (self) {
        if (!_weakPropertyNames) {
            _weakPropertyNames = [self.weakProperties valueForKey:@"name"];
        }
        return _weakPropertyNames;
    }
}

- (NSArray *)nonWeakPropertyNames
{
    @synchronized (self) {
        if (!_nonWeakPropertyNames) {
            _nonWeakPropertyNames = [self.nonWeakProperties valueForKey:@"name"];
        }
        return _nonWeakPropertyNames;
    }
}

@end
