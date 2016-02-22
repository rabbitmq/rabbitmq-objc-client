#import <Foundation/Foundation.h>

@interface AMQParser : NSObject

- (instancetype)initWithData:(NSData *)data;

- (NSDictionary *)parseFieldTable;
- (char)parseOctet;
- (NSString *)parseLongString;
- (NSString *)parseShortString;
- (NSNumber *)parseLongUInt;
- (NSNumber *)parseLongLongUInt;
- (NSNumber *)parseShortUInt;
- (BOOL)parseBoolean;
- (NSData *)dataWithLength:(NSUInteger)length;

@end
