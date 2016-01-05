//
//  RMQClientChannel.m
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import "RMQClientChannel.h"

@implementation RMQClientChannel
- (RMQClientQueue *)queue:(NSString *)queueName autoDelete:(BOOL)shouldAutoDelete {
    return [RMQClientQueue new];
}
- (RMQClientExchange *)defaultExchange {
    return [RMQClientExchange new];
}
@end
