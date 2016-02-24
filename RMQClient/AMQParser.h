#import <Foundation/Foundation.h>

@interface AMQParser : NSObject

- (nonnull instancetype)initWithData:(nonnull NSData *)data;

- (nonnull NSDictionary *)parseFieldTable;
- (char)parseOctet;
- (nonnull NSString *)parseLongString;
- (nonnull NSString *)parseShortString;
- (UInt32)parseLongUInt;
- (UInt64)parseLongLongUInt;
- (UInt16)parseShortUInt;
- (BOOL)parseBoolean;
- (nonnull NSData *)parseLength:(UInt32)length;

@end
