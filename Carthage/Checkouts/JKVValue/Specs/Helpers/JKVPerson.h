#import "JKVValue.h"
#import <CoreGraphics/CoreGraphics.h>

@interface JKVPerson : JKVValue
@property (nonatomic, strong, readonly) NSString<NSCopying> *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, assign, readonly) NSInteger age;
@property (nonatomic, assign, getter=isMarried, readonly) BOOL married;
@property (atomic, assign, readonly) CGFloat height;
@property (nonatomic, strong, readonly) NSArray *siblings;

// objc doesn't mark this as weak if it is a readonly attribute
@property (nonatomic, weak) id parent;
@property (nonatomic, strong) id child;

@property (nonatomic, readonly) id propertyWithoutIVar;

- (id)initWithFixtureData;
- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
                    age:(NSInteger)age
                married:(BOOL)married
                 height:(CGFloat)height
                 parent:(id)parent
               siblings:(NSArray *)siblings
                  child:(id)child;

@end
