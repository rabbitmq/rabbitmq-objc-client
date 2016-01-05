//
//  AMQURI.h
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMQURI : NSObject
+ (id)parse:(NSString *)uri error:(NSError **)error;
@end
