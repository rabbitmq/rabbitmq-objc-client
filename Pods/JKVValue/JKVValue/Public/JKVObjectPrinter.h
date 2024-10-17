#import <Foundation/Foundation.h>

/*! This manages description generation of JKVValue objects.
 *
 *  In addition, this class can swizzle out default descriptions of objective-c container classes:
 *  NSArray, NSDictionary, NSSet for more readability when debugging.
 *
 *  Other than swizzling container classes, this class isn't used directly.
 */
@interface JKVObjectPrinter : NSObject

/*! Swizzles out NSArray, NSDictionary, NSSet to emit prettier description strings.
 *
 *  Can be undone with +[unswizzleContainers].
 */
+ (void)swizzleContainers;

/*! Unswizzles NSArray, NSDictionary, NSSet to emit prettier description strings.
 *
 *  Can be undone with +[unswizzleContainers].
 */
+ (void)unswizzleContainers;

@end
