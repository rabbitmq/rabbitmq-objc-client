#import "JKVPerson.h"

@interface JKVMutablePerson : JKVPerson
@property (nonatomic, strong, readwrite) NSString<NSCopying> *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;
@property (nonatomic, assign, readwrite) NSInteger age;
@property (nonatomic, assign, readwrite, getter=isMarried) BOOL married;
@property (atomic, assign, readwrite) CGFloat height;
@property (nonatomic, weak, readwrite) id parent;
@property (nonatomic, strong, readwrite) NSArray *siblings;

// SDK 8.0+ makes hashes properties.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@property (atomic, readonly) NSUInteger hash;
#endif

@end

