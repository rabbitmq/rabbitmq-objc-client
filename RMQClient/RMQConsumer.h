#import <Foundation/Foundation.h>
#import "RMQDeliveryInfo.h"
#import "RMQMessage.h"

typedef void (^RMQConsumer)(RMQDeliveryInfo * _Nonnull deliveryInfo, RMQMessage * _Nonnull message);