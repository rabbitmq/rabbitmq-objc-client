#import "JKVProperty.h"

@interface JKVNonZeroSetterVisitor : NSObject <JKVPropertyEncodingTypeVisitor>

- (id)initWithObject:(id)object;

@end
