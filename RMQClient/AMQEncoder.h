#import <Foundation/Foundation.h>

@interface AMQEncoder : NSCoder

@property (nonatomic, readonly) NSMutableData *data;

- (NSData *)frameForClassID:(NSNumber *)classID
                   methodID:(NSNumber *)methodID;

@end
