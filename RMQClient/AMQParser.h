#import <Foundation/Foundation.h>

@interface AMQParser : NSObject

- (instancetype)initWithData:(NSData *)data;

- (NSDictionary *)parseFieldTable;
- (char)parseOctet;
- (NSString *)parseLongString;
- (NSString *)parseShortString;
- (UInt32)parseLongUInt;
- (UInt64)parseLongLongUInt;
- (UInt16)parseShortUInt;
- (BOOL)parseBoolean;
- (NSData *)rest;

@end
