#import <Foundation/Foundation.h>
#import "RMQDeliveryInfo.h"
#import "RMQMessage.h"

typedef void (^RMQConsumer)(RMQDeliveryInfo * _Nonnull, RMQMessage * _Nonnull);