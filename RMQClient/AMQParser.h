#import <Foundation/Foundation.h>
#import "AMQProtocol.h"

@interface AMQParser : NSObject

- (AMQProtocolConnectionStart *)parse:(NSData *)data;

- (NSDictionary *)parseFieldTable:(const char **)cursor
                              end:(const char *)end;

- (UInt32)parseLongUInt:(const char **)cursor
                    end:(const char *)end;

- (NSString *)parseShortString:(const char **)cursor
                           end:(const char *)end;

- (NSString *)parseLongString:(const char **)cursor
                          end:(const char *)end;

- (BOOL)parseBoolean:(const char **)cursor
                 end:(const char *)end;

@end
