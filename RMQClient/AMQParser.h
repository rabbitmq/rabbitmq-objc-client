#import <Foundation/Foundation.h>
#import "AMQProtocolValues.h"

@interface AMQParser : NSObject

- (AMQTable *)parseFieldTable:(const char **)cursor
                          end:(const char *)end;

- (AMQOctet *)parseOctet:(const char **)cursor
                     end:(const char *)end;

- (AMQLongstr *)parseLongString:(const char **)cursor
                            end:(const char *)end;

- (AMQShortstr *)parseShortString:(const char **)cursor
                              end:(const char *)end;

- (AMQLong *)parseLongUInt:(const char **)cursor
                       end:(const char *)end;

- (AMQShort *)parseShortUInt:(const char **)cursor
                         end:(const char *)end;

@end
