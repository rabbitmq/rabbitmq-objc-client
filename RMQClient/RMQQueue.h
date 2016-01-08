#import <Foundation/Foundation.h>

@interface RMQQueue : NSObject
- (void)subscribe:(void (^)(NSDictionary *info,
                            NSDictionary *meta,
                            NSDictionary *p))response;
@property (nonatomic) NSString *name;
@end
