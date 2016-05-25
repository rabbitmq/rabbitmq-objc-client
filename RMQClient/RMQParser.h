#import <Foundation/Foundation.h>

@class RMQValue;
@protocol RMQFieldValue;
@interface RMQParser : NSObject

- (nonnull instancetype)initWithData:(nonnull NSData *)data;

- (nonnull NSDictionary<NSString *, RMQValue<RMQFieldValue> *> *)parseFieldTable;
- (char)parseOctet;
- (nonnull NSString *)parseLongString;
- (nonnull NSString *)parseShortString;
- (UInt32)parseLongUInt;
- (UInt64)parseLongLongUInt;
- (nonnull NSDate *)parseTimestamp;
- (UInt16)parseShortUInt;
- (BOOL)parseBoolean;
- (nonnull NSData *)parseLength:(UInt32)length;

@end
