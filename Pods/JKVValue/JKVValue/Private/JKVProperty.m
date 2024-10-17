#import "JKVProperty.h"
#import <objc/runtime.h>

@implementation JKVProperty

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes
{
    if (self = [super init]) {
        self.name = name;
        self.attributes = attributes;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ name=%@ attributes=%@>", NSStringFromClass([self class]), self.name, self.attributes];
}

- (NSString *)encodingType
{
    return self.attributes[@"T"];
}

- (NSString *)ivarName
{
    return self.attributes[@"V"];
}

- (NSString *)encodingTypeObjCDeclaration
{
    NSString *encodingType = self.encodingType;
    if (self.isObjCObjectType) {
        if (encodingType.length > 3 &&
            [encodingType characterAtIndex:1] == '"' &&
            [encodingType characterAtIndex:encodingType.length-1] == '"') {
            return [encodingType substringWithRange:NSMakeRange(2, encodingType.length - 3)];
        }
        return @"NSObject";
    }
    return nil;
}

- (Class)classType
{
    if (!self.isObjCObjectType) {
        return nil;
    }
    NSString *declaration = [self encodingTypeObjCDeclaration];
    NSString *className = @"";
    NSRange protocolStart = [declaration rangeOfString:@"<"];
    if (protocolStart.location == NSNotFound){
        className = declaration;
    } else {
        className = [declaration substringToIndex:protocolStart.location];
    }
    return NSClassFromString(className);
}

- (BOOL)isEncodingType:(const char *)encoding
{
    return strcmp(self.encodingType.UTF8String, encoding) == 0;
}

- (BOOL)isObjCObjectType
{
    return [self.encodingType characterAtIndex:0] == '@';
}

- (BOOL)isWeak
{
    return self.attributes[@"W"] != nil;
}

- (BOOL)isNonAtomic
{
    return self.attributes[@"N"] != nil;
}

- (BOOL)isReadOnly
{
    return self.attributes[@"R"] != nil;
}

- (void)visitEncodingType:(id<JKVPropertyEncodingTypeVisitor>)visitor
{
    SEL selector;
    if ([self isEncodingType:@encode(int64_t)]) {
        selector = @selector(propertyWasInt64:);
    } else if ([self isEncodingType:@encode(int32_t)]) {
        selector = @selector(propertyWasInt32:);
    } else if ([self isEncodingType:@encode(int16_t)]) {
        selector = @selector(propertyWasInt16:);
    } else if ([self isEncodingType:@encode(float)]) {
        selector = @selector(propertyWasFloat:);
    } else if ([self isEncodingType:@encode(double)]) {
        selector = @selector(propertyWasDouble:);
    } else if ([self isEncodingType:@encode(BOOL)]) {
        selector = @selector(propertyWasBool:);
#ifdef CGFLOAT_DEFINED
    } else if ([self isEncodingType:@encode(CGPoint)]) {
        selector = @selector(propertyWasCGPoint:);
    } else if ([self isEncodingType:@encode(CGSize)]) {
        selector = @selector(propertyWasCGSize:);
    } else if ([self isEncodingType:@encode(CGRect)]) {
        selector = @selector(propertyWasCGRect:);
#endif
#if TARGET_OS_IPHONE
    } else if ([self isEncodingType:@encode(UIEdgeInsets)]) {
        selector = @selector(propertyWasUIEdgeInsets:);
    } else if ([self isEncodingType:@encode(UIOffset)]) {
        selector = @selector(propertyWasUIOffset:);
#else
    } else if ([self isEncodingType:@encode(NSPoint)]) {
        selector = @selector(propertyWasNSPoint:);
    } else if ([self isEncodingType:@encode(NSSize)]) {
        selector = @selector(propertyWasNSSize:);
    } else if ([self isEncodingType:@encode(NSRect)]) {
        selector = @selector(propertyWasNSRect:);
#endif
    } else if ([self isObjCObjectType]) {
        selector = @selector(propertyWasObjCObject:);
    } else {
        selector = @selector(propertyWasUnknownType:);
    }

    if ([visitor respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [visitor performSelector:selector withObject:self];
#pragma clang diagnostic pop
    }
}

@end
