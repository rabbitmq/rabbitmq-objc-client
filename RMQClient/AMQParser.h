#import <Foundation/Foundation.h>

@interface AMQParser : NSObject

- (NSDictionary *)parseFieldTable:(const char **)cursor
                              end:(const char *)end;

- (NSNumber *)parseChar:(const char **)cursor
                    end:(const char *)end;

- (NSString *)parseLongString:(const char **)cursor
                          end:(const char *)end;

@end
