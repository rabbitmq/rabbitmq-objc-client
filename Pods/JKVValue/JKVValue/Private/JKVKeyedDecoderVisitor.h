#import "JKVProperty.h"

@interface JKVKeyedDecoderVisitor : NSObject <JKVPropertyEncodingTypeVisitor>

- (id)initWithCoder:(NSCoder *)decoder forObject:(NSObject *)target;

@end
