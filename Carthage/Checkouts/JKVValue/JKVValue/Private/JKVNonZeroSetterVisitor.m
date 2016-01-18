#import "JKVNonZeroSetterVisitor.h"

@interface JKVNonZeroSetterVisitor ()
@property (strong, nonatomic) id object;
@end

@implementation JKVNonZeroSetterVisitor

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        self.object = object;
    }
    return self;
}

#pragma mark - <JKVPropertyEncodingTypeVisitor>

- (void)propertyWasInt64:(JKVProperty *)property
{
    [self.object setValue:@(1) forKey:property.name];
}

- (void)propertyWasInt32:(JKVProperty *)property
{
    [self.object setValue:@(1) forKey:property.name];
}

- (void)propertyWasInt16:(JKVProperty *)property
{
    [self.object setValue:@(1) forKey:property.name];
}

- (void)propertyWasFloat:(JKVProperty *)property
{
    [self.object setValue:@(1) forKey:property.name];
}

- (void)propertyWasDouble:(JKVProperty *)property
{
    [self.object setValue:@(1) forKey:property.name];
}

- (void)propertyWasBool:(JKVProperty *)property
{
    [self.object setValue:@YES forKey:property.name];
}

- (void)propertyWasObjCObject:(JKVProperty *)property
{
    id value = nil;
    if ([property.classType isEqual:[NSString class]]) {
        value = property.name;
    } else {
        value = [[property.classType alloc] init];
    }
    [self.object setValue:value forKey:property.name];
}

- (void)propertyWasUnknownType:(JKVProperty *)property
{
    [NSException raise:@"Unknown Encoding Type" format:@"Unknown encoding type: %@ for %@", property.encodingType, property.name];
}

#pragma mark - OS Specific

#if TARGET_OS_IPHONE

- (void)propertyWasCGPoint:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithCGPoint:CGPointMake(1, 2)]
                   forKey:property.name];
}
- (void)propertyWasCGSize:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithCGSize:CGSizeMake(1, 2)]
                   forKey:property.name];
}

- (void)propertyWasCGRect:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithCGRect:CGRectMake(1, 2, 3, 4)]
                   forKey:property.name];
}

- (void)propertyWasCGAffineTransform:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithCGAffineTransform:CGAffineTransformMake(1, 2, 3, 4, 5, 6)]
                   forKey:property.name];
}

- (void)propertyWasUIEdgeInsets:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(1, 2, 3, 4)]
                   forKey:property.name];
}

- (void)propertyWasUIOffset:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithUIOffset:UIOffsetMake(1, 2)]
                   forKey:property.name];
}

#else

- (void)propertyWasCGPoint:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithPoint:CGPointMake(1, 2)]
                   forKey:property.name];
}
- (void)propertyWasCGSize:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithSize:CGSizeMake(1, 2)]
                   forKey:property.name];
}

- (void)propertyWasCGRect:(JKVProperty *)property
{
    [self.object setValue:[NSValue valueWithRect:CGRectMake(1, 2, 3, 4)]
                   forKey:property.name];
}

- (void)propertyWasNSPoint:(JKVProperty *)property
{
    [self propertyWasCGPoint:property];
}

- (void)propertyWasNSSize:(JKVProperty *)property
{
    [self propertyWasCGSize:property];
}

- (void)propertyWasNSRect:(JKVProperty *)property
{
    [self propertyWasCGRect:property];
}

#endif

@end
