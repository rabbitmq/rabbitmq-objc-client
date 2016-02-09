#import <Foundation/Foundation.h>
#import "RMQQueue.h"
#import "RMQExchange.h"

@interface RMQChannel : NSObject
- (RMQQueue *)queue:(NSString *)queueName
         autoDelete:(BOOL)shouldAutoDelete
          exclusive:(BOOL)isExclusive;
- (RMQExchange *)defaultExchange;
- (RMQChannel *)open;
- (void)close;
- (BOOL)isOpen;
@end
