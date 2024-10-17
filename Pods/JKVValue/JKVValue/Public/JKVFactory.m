#import "JKVFactory.h"
#import "JKVClassInspector.h"
#import "JKVProperty.h"
#import "JKVNonZeroSetterVisitor.h"
#import "JKVValueImpl.h"

@interface JKVValue ()
- (id)initFromJKVValue;
@end

@interface JKVFactory ()
@property (strong, nonatomic) JKVClassInspector *inspector;
@end

@implementation JKVFactory

+ (instancetype)factoryForClass:(Class)aClass
{
    return [[self alloc] initWithClass:aClass];
}

- (id)init
{
    [NSException raise:@"JKVFactoryError" format:@"Subclasses should override %@ for default factory setup", NSStringFromSelector(@selector(init))];
    return nil;
}

- (id)initWithClass:(Class)aClass
{
    return [self initWithClass:aClass properties:@{}];
}

- (id)initWithClass:(Class)aClass properties:(NSDictionary *)properties
{
    self = [super init];
    if (self) {
        self.productClass = aClass;
        self.properties = properties;
    }
    return self;
}

- (instancetype)factoryWithProperties:(NSDictionary *)properties
{
    NSMutableDictionary *newProperties = [self.properties mutableCopy];
    for (id key in properties.allKeys) {
        newProperties[key] = properties[key];
    }
    return [[[self class] alloc] initWithClass:self.productClass properties:newProperties];
}

- (id)object
{
    id object = [self.productClass alloc];
    if ([object respondsToSelector:@selector(initFromJKVValue)]) {
        object = [object initFromJKVValue];
    } else {
        object = [object init];
    }

    JKVNonZeroSetterVisitor *visitor = [[JKVNonZeroSetterVisitor alloc] initWithObject:object];
    for (JKVProperty *property in self.inspector.nonWeakProperties) {
        [property visitEncodingType:visitor];
    }

    for (NSString *propertyName in self.properties) {
        id value = self.properties[propertyName];
        if (value == [NSNull null]) {
            value = nil;
        }

        [object setValue:value forKey:propertyName];
    }

    return object;
}

- (id)objectWithProperties:(NSDictionary *)properties
{
    return [[self factoryWithProperties:properties] object];
}

#pragma mark - Subclass-available methods

+ (id)buildObject
{
    return [[self new] object];
}

+ (id)buildObjectWithProperties:(NSDictionary *)properties
{
    return [[self new] objectWithProperties:properties];
}

#pragma mark - Properties

- (void)setProductClass:(Class)productClass
{
    _productClass = productClass;
    if (_productClass) {
        self.inspector = [JKVClassInspector inspectorForClass:_productClass];
    }
}

@end
