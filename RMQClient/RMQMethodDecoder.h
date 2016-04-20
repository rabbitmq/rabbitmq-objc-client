#import <Foundation/Foundation.h>
#import "RMQValues.h"
#import "RMQParser.h"

@interface RMQMethodDecoder : NSObject

- (nonnull instancetype)initWithParser:(nonnull RMQParser *)parser;
- (nonnull id)decode;

@end
