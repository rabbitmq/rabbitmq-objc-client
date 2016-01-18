#import <Foundation/Foundation.h>

@interface KeyedUnarchiver : NSKeyedUnarchiver
@property (atomic, readwrite) BOOL allowsKeyedCoding;
@end
