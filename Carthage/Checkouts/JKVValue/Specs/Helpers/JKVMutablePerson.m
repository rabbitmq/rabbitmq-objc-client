#import "JKVMutablePerson.h"

@implementation JKVMutablePerson

@synthesize firstName;
@synthesize lastName;
@synthesize age;
@synthesize married;
@synthesize height;
@synthesize parent;
@synthesize siblings;

@dynamic hash;

- (BOOL)JKV_isMutable
{
    return YES;
}

@end
