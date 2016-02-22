#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@interface AMQParser : NSObject

- (instancetype)initWithData:(NSData *)data;

- (AMQTable *)parseFieldTable;
- (AMQOctet *)parseOctet;
- (AMQLongstr *)parseLongString;
- (AMQShortstr *)parseShortString;
- (AMQLong *)parseLongUInt;
- (AMQShort *)parseShortUInt;

@end
