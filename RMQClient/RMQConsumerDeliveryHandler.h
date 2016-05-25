#import <Foundation/Foundation.h>
#import "RMQMessage.h"

typedef void (^RMQConsumerDeliveryHandler)(RMQMessage * _Nonnull message);