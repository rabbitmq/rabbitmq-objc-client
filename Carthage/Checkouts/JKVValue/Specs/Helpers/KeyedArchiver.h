#import <Foundation/Foundation.h>

@interface KeyedArchiver : NSKeyedArchiver
@property (atomic, readwrite) BOOL allowsKeyedCoding;
@end
