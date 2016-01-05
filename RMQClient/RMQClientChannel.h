//
//  RMQClientChannel.h
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMQClientQueue.h"
#import "RMQClientExchange.h"

@interface RMQClientChannel : NSObject
- (RMQClientQueue *)queue:(NSString *)queueName autoDelete:(BOOL)shouldAutoDelete;
- (RMQClientExchange *)defaultExchange;
@end
