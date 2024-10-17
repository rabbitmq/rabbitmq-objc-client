#import "JKVKeyedDecoderVisitor.h"

@interface JKVKeyedDecoderVisitor ()
@property (strong, nonatomic) NSCoder *coder;
@property (strong, nonatomic) NSObject *target;
@end

@implementation JKVKeyedDecoderVisitor

- (id)initWithCoder:(NSCoder *)decoder forObject:(NSObject *)target;
{
    if (self = [super init]) {
        self.coder = decoder;
        self.target = target;

        if (!decoder.allowsKeyedCoding) {
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Only Keyed-Archivers are supported"];
        }
    }
    return self;
}

#pragma mark - <JKVPropertyEncodingTypeVisitor>

- (void)propertyWasInt64:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeInt64ForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasInt32:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeInt64ForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasInt16:(JKVProperty *)property
{
    [self.target setValue:@((int16_t)[self.coder decodeInt32ForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasFloat:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeFloatForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasDouble:(JKVProperty *)property
{
    [self.target setValue:@([self.coder decodeDoubleForKey:property.name])
                   forKey:property.name];
}

- (void)propertyWasBool:(JKVProperty *)property
{
    [self.target setValue:([self.coder decodeBoolForKey:property.name] ? @YES : @NO)
                   forKey:property.name];
}

- (void)propertyWasObjCObject:(JKVProperty *)property
{
    Class theClass = property.classType;
    id value = [self.coder decodeObjectOfClass:theClass forKey:property.name];
    if (self.coder.requiresSecureCoding && ![value isKindOfClass:theClass]) {
        [NSException raise:NSInvalidUnarchiveOperationException format:@"Failed to unarchive '%@' as '%@'", property.name, NSStringFromClass(theClass)];
    }
    [self.target setValue:value forKey:property.name];
}

- (void)propertyWasUnknownType:(JKVProperty *)property
{
    [NSException raise:@"Unknown Encoding Type" format:@"Unknown encoding type: %@ for %@", property.encodingType, property.name];
}

#pragma mark - OS Specific

#if TARGET_OS_IPHONE

- (void)propertyWasCGPoint:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGPoint:[self.coder decodeCGPointForKey:property.name]]
                   forKey:property.name];
}
- (void)propertyWasCGSize:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGSize:[self.coder decodeCGSizeForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasCGRect:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGRect:[self.coder decodeCGRectForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasCGAffineTransform:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithCGAffineTransform:[self.coder decodeCGAffineTransformForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasUIEdgeInsets:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithUIEdgeInsets:[self.coder decodeUIEdgeInsetsForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasUIOffset:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithUIOffset:[self.coder decodeUIOffsetForKey:property.name]]
                   forKey:property.name];
}

#else

- (void)propertyWasCGPoint:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithPoint:[self.coder decodePointForKey:property.name]]
                   forKey:property.name];
}
- (void)propertyWasCGSize:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithSize:[self.coder decodeSizeForKey:property.name]]
                   forKey:property.name];
}

- (void)propertyWasCGRect:(JKVProperty *)property
{
    [self.target setValue:[NSValue valueWithRect:[self.coder decodeRectForKey:property.name]]
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
