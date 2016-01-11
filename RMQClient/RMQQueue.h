#import <Foundation/Foundation.h>

@interface RMQQueue : NSObject
@property (nonatomic, readonly) NSString *name;
- (void)subscribe:(void (^)(NSDictionary *info,
                            NSDictionary *meta,
                            NSDictionary *p))response;
@end
