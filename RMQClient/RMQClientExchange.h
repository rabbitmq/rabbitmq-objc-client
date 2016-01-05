//
//  RMQClientExchange.h
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMQClientExchange : NSObject
- (void)publish:(NSString *)message routingKey:(NSString *)key;
@end
