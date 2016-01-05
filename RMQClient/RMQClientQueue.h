//
//  RMQClientQueue.h
//  RMQClient
//
//  Created by Pivotal on 05/01/2016.
//  Copyright © 2016 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMQClientQueue : NSObject
- (void)subscribe:(void (^)(NSDictionary *info,
                            NSDictionary *meta,
                            NSDictionary *p))response;
@property (nonatomic) NSString *name;
@end
