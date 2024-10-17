#import "JKVProperty.h"

@interface JKVKeyedEncoderVisitor : NSObject <JKVPropertyEncodingTypeVisitor>
- (id)initWithCoder:(NSCoder *)coder forObject:(NSObject *)target;
@end
