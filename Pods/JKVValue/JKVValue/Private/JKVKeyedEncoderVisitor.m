#import "JKVKeyedEncoderVisitor.h"

@interface JKVKeyedEncoderVisitor ()
@property (strong, nonatomic) NSCoder *coder;
@property (strong, nonatomic) NSObject *target;
@end

@implementation JKVKeyedEncoderVisitor

- (id)initWithCoder:(NSCoder *)coder forObject:(NSObject *)target;
{
    if (self = [super init]) {
        self.coder = coder;
        self.target = target;

        if (!coder.allowsKeyedCoding) {
            [NSException raise:NSInvalidArchiveOperationException format:@"Only Keyed-Unarchivers are supported"];
        }
    }
    return self;
}

#pragma mark - <JKVPropertyEncodingTypeVisitor>

- (void)propertyWasInt64:(JKVProperty *)property
{
    [self.coder encodeInt64:[[self.target valueForKey:property.name] longLongValue]
                     forKey:property.name];
}

- (void)propertyWasInt32:(JKVProperty *)property
{
    [self.coder encodeInt32:[[self.target valueForKey:property.name] intValue]
                     forKey:property.name];
}

- (void)propertyWasInt16:(JKVProperty *)property
{
    [self.coder encodeInt32:[[self.target valueForKey:property.name] shortValue]
                     forKey:property.name];
}

- (void)propertyWasFloat:(JKVProperty *)property
{
    [self.coder encodeFloat:[[self.target valueForKey:property.name] floatValue]
                     forKey:property.name];
}

- (void)propertyWasDouble:(JKVProperty *)property
{
    [self.coder encodeDouble:[[self.target valueForKey:property.name] doubleValue]
                      forKey:property.name];
}

- (void)propertyWasBool:(JKVProperty *)property
{
    [self.coder encodeBool:[[self.target valueForKey:property.name] boolValue]
                    forKey:property.name];
}

- (void)propertyWasObjCObject:(JKVProperty *)property
{
    id value = [self.target valueForKey:property.name];
    if (property.isWeak){
        [self.coder encodeConditionalObject:value forKey:property.name];
    } else {
        [self.coder encodeObject:value forKey:property.name];
    }
}

- (void)propertyWasUnknownType:(JKVProperty *)property
{
    [NSException raise:@"Unknown Encoding Type" format:@"Unknown encoding type: %@ for %@", property.encodingType, property.name];
}

#pragma mark - OS Specific

#if TARGET_OS_IPHONE

- (void)propertyWasCGPoint:(JKVProperty *)property
{
    [self.coder encodeCGPoint:[[self.target valueForKey:property.name] CGPointValue]
                       forKey:property.name];
}

- (void)propertyWasCGSize:(JKVProperty *)property
{
    [self.coder encodeCGSize:[[self.target valueForKey:property.name] CGSizeValue]
                      forKey:property.name];
}

- (void)propertyWasCGRect:(JKVProperty *)property
{
    [self.coder encodeCGRect:[[self.target valueForKey:property.name] CGRectValue]
                      forKey:property.name];
}

- (void)propertyWasCGAffineTransform:(JKVProperty *)property
{
    [self.coder encodeCGAffineTransform:[[self.target valueForKey:property.name] CGAffineTransformValue]
                                 forKey:property.name];
}

- (void)propertyWasUIEdgeInsets:(JKVProperty *)property
{
    [self.coder encodeUIEdgeInsets:[[self.target valueForKey:property.name] UIEdgeInsetsValue]
                            forKey:property.name];
}

- (void)propertyWasUIOffset:(JKVProperty *)property
{
    [self.coder encodeUIOffset:[[self.target valueForKey:property.name] UIOffsetValue]
                        forKey:property.name];
}

#else

- (void)propertyWasCGPoint:(JKVProperty *)property
{
    [self.coder encodePoint:[[self.target valueForKey:property.name] pointValue]
                      forKey:property.name];
}
- (void)propertyWasCGSize:(JKVProperty *)property
{
    [self.coder encodeSize:[[self.target valueForKey:property.name] sizeValue]
                    forKey:property.name];
}

- (void)propertyWasCGRect:(JKVProperty *)property
{
    [self.coder encodeRect:[[self.target valueForKey:property.name] rectValue]
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
