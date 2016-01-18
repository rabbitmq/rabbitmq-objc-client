#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@class JKVProperty;

@protocol JKVPropertyEncodingTypeVisitor <NSObject>
@required
- (void)propertyWasInt64:(JKVProperty *)property;
- (void)propertyWasInt32:(JKVProperty *)property;
- (void)propertyWasInt16:(JKVProperty *)property;
- (void)propertyWasFloat:(JKVProperty *)property;
- (void)propertyWasDouble:(JKVProperty *)property;
- (void)propertyWasBool:(JKVProperty *)property;
- (void)propertyWasObjCObject:(JKVProperty *)property;
- (void)propertyWasUnknownType:(JKVProperty *)property;

@optional
// CoreGraphics
- (void)propertyWasCGPoint:(JKVProperty *)property;
- (void)propertyWasCGSize:(JKVProperty *)property;
- (void)propertyWasCGRect:(JKVProperty *)property;
// UIKit - iOS Only
- (void)propertyWasUIEdgeInsets:(JKVProperty *)property;
- (void)propertyWasUIOffset:(JKVProperty *)property;
// AppKit - OSX Only
- (void)propertyWasNSPoint:(JKVProperty *)property;
- (void)propertyWasNSSize:(JKVProperty *)property;
- (void)propertyWasNSRect:(JKVProperty *)property;
@end

@interface JKVProperty : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *attributes;

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (NSString *)encodingType;
- (NSString *)ivarName;
- (Class)classType;
- (BOOL)isEncodingType:(const char *)encoding;
- (BOOL)isObjCObjectType;
- (BOOL)isWeak;
- (BOOL)isNonAtomic;
- (BOOL)isReadOnly;
- (void)visitEncodingType:(id<JKVPropertyEncodingTypeVisitor>)visitor;

@end
