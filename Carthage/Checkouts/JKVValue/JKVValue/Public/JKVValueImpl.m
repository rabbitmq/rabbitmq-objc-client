#import "JKVValue.h"
#import "JKVProperty.h"
#import "JKVKeyedDecoderVisitor.h"
#import "JKVKeyedEncoderVisitor.h"
#import "JKVClassInspector.h"
#import "JKVObjectPrinter-Protected.h"

// We need ivars to avoid "picking" ourselves up from the runtime introspection
// Namespaced to avoid getting clobbered by subclasses
@interface JKVValue () {
    NSArray *_JKV_propertiesForIdentity;
    NSArray *_JKV_propertiesToAssignCopy;
    JKVClassInspector *_JKV_inspector;
}

- (id)initFromJKVValue;
- (NSArray *)JKV_cachedPropertyNamesForIdentity;
- (NSArray *)JKV_cachedPropertyNamesToAssignCopy;
- (JKVClassInspector *)JKV_inspector;
@end


@implementation JKVValue

// like -[init], but allows us to still work if our
// subclasses override -[init] to be not recognized.
- (id)initFromJKVValue
{
    return self = [super init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        JKVKeyedDecoderVisitor *visitor = [[JKVKeyedDecoderVisitor alloc] initWithCoder:aDecoder forObject:self];
        for (JKVProperty *property in self.JKV_inspector.propertiesBackedByInstanceVariables) {
            [property visitEncodingType:visitor];
        }
    }
    return self;
}

#pragma mark - <NSSecureCoding>

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    JKVKeyedEncoderVisitor *visitor = [[JKVKeyedEncoderVisitor alloc] initWithCoder:aCoder forObject:self];
    for (JKVProperty *property in self.JKV_inspector.propertiesBackedByInstanceVariables) {
        [property visitEncodingType:visitor];
    }
}

#pragma - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    if (![self JKV_isMutable]) {
        return self;
    }

    id cloned = [[[self JKV_immutableClass] allocWithZone:zone] initFromJKVValue];
    return [self.JKV_inspector copyToObject:cloned
                                 fromObject:self
                                     inZone:zone
                              propertyNames:self.JKV_cachedPropertyNamesForIdentity
                          weakPropertyNames:self.JKV_cachedPropertyNamesToAssignCopy];
}


#pragma - <NSMutableCopying>

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id cloned = [[[self JKV_mutableClass] allocWithZone:zone] initFromJKVValue];
    return [self.JKV_inspector copyToObject:cloned
                                 fromObject:self
                                     inZone:zone
                              propertyNames:self.JKV_cachedPropertyNamesForIdentity
                          weakPropertyNames:self.JKV_cachedPropertyNamesToAssignCopy];
}

#pragma - <NSObject>

- (NSString *)description
{
    return [self debugDescription];
}

- (NSString *)debugDescription
{
    return [JKVObjectPrinter descriptionForObject:self
                                   withProperties:self.JKV_inspector.propertiesBackedByInstanceVariables];
}

- (BOOL)isEqual:(id)object
{
    return [self.JKV_inspector isObject:self
                          equalToObject:object
                      withPropertyNames:self.JKV_cachedPropertyNamesForIdentity];

}

- (NSUInteger)hash
{
    return [self.JKV_inspector hashObject:self byPropertyNames:self.JKV_cachedPropertyNamesForIdentity];
}

#pragma mark - Public

- (NSDictionary *)differenceToObject:(id)otherValueObject
{
    NSMutableDictionary *differences = [NSMutableDictionary dictionary];
    if (self == otherValueObject) {
        return differences;
    }

    if (![[otherValueObject class] isSubclassOfClass:[self class]] && ![[self class] isSubclassOfClass:[otherValueObject class]]) {
        differences[@"class"] = @[[self class], [otherValueObject class]];
        return differences;
    }
    for (NSString *name in self.JKV_cachedPropertyNamesForIdentity) {
        id value = [self valueForKey:name];
        id otherValue = [otherValueObject valueForKey:name];
        if (value != otherValue && ![value isEqual:otherValue]){
            differences[name] = @[value ?: [NSNull null], otherValue ?: [NSNull null]];
        }
    }
    return differences;
}

#pragma mark - Protected

- (BOOL)JKV_isMutable
{
    return NO;
}

- (Class)JKV_mutableClass
{
    return [self class];
}

- (Class)JKV_immutableClass
{
    return [self class];
}

- (NSArray *)JKV_propertyNamesForIdentity
{
    return self.JKV_inspector.nonWeakPropertyNames;
}

- (NSArray *)JKV_propertyNamesToAssignCopy
{
    return self.JKV_inspector.weakPropertyNames;
}

#pragma mark - Private

- (NSArray *)JKV_cachedPropertyNamesForIdentity
{
    if (!_JKV_propertiesForIdentity){
        NSArray *propertyNames = [self JKV_propertyNamesForIdentity];
        NSArray *properties = self.JKV_inspector.propertiesBackedByInstanceVariables;
        NSSet *whitelist = [NSSet setWithArray:propertyNames];
        NSPredicate *whitelistedNamePredicate = [NSPredicate predicateWithFormat:@"name in %@", whitelist];
        properties = [properties filteredArrayUsingPredicate:whitelistedNamePredicate];
        _JKV_propertiesForIdentity = [properties valueForKey:@"name"];
    }
    return _JKV_propertiesForIdentity;
}

- (NSArray *)JKV_cachedPropertyNamesToAssignCopy
{
    if (!_JKV_propertiesToAssignCopy){
        NSArray *propertyNames = [self JKV_propertyNamesToAssignCopy];
        NSArray *properties = self.JKV_inspector.propertiesBackedByInstanceVariables;
        NSSet *whitelist = [NSSet setWithArray:propertyNames];
        NSPredicate *whitelistedNamePredicate = [NSPredicate predicateWithFormat:@"name in %@", whitelist];
        properties = [properties filteredArrayUsingPredicate:whitelistedNamePredicate];
        _JKV_propertiesToAssignCopy = [properties valueForKey:@"name"];
    }
    return _JKV_propertiesToAssignCopy;
}

- (JKVClassInspector *)JKV_inspector
{
    if (!_JKV_inspector) {
        _JKV_inspector = [JKVClassInspector inspectorForClass:[self class]];
    }
    return _JKV_inspector;
}

@end
