JKVValue
========

Simple Value Objects for Objective-C.

[Value Objects][] are great for well-designed programs!

They're great for documenting data from an API or your internal
application data, but are terrible to maintain.

When you add (or change) a property, you usually have to do:

- Add the `@property`
- Add property to the constructor (optional)
- Add it to `-[mutableCopyWithZone:]` if it supports NSMutableCopying
- Add it to `-[copyWithZone:]` if it supports NSCopying
- Add it to `-[isEqual:]` to support equality for that modified property
- Add it to `-[hash]` to support hashing
- Add it to `-[initWithCoder:]` to support deserialization
- Add it to `-[encodeWithCoder:]` to support serialization (NSSecureCoding)
- Add it to `-[description]` for nice logging output
- Add it to `-[debugDescription]` for nice object printouts in a debugger.

And forget about doing the right thing, and having both mutable and immutable
versions of value objects like Apple's Foundation data structures...
until now!

JKVValue simplifies your work to only setting the @property and constructor!

[Value Objects]: http://en.wikipedia.org/wiki/Value_object

Installation
============

CocoaPods
---------

If you like pod'n it up:

    pod "JKVValue", "~> 1.3.0"

Carthage
--------

Add to your `Cartfile`:

    github "jeffh/JKVValue" ~> 1.3

Submodule
---------

If you like git submodules add this project and adding it to your project:

    git submodule add https://github.com/jeffh/JKVValue <Externals/JKVValue>
    # checking out the stable version
    cd <Externals/JKVValue>
    git co tag v1.3.2

And then add the JKVValue static library and public headers for your dependencies.

Usage
=====

There are two classes you can subclass, JKVValue and JKVMutableValue.
Any properties you declare will automatically be detected and have their
corresponding methods in NSCopying, NSMutableCopying, NSCoding, NSObject
protocols supported automatically:

```objc
#import "JKVValue.h"

@interface MyPerson : JKVValue
@property (strong, nonatomic, readonly) NSString *firstName;
@property (strong, nonatomic, readonly) NSString *lastName;

- (id)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;
@end

@interface MyPerson ()
@property (strong, nonatomic, readwrite) NSString *firstName;
@property (strong, nonatomic, readwrite) NSString *lastName;
@end

@implementation MyPerson

- (id)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    if (self = [super init]) {
        self.firstName = firstName;
        self.lastName = lastName;
    }
    return self;
}

@end
```

That's it! All the cool methods are supported now:

```objc
MyPerson *person = [[MyPerson alloc] initWithFirstName:@"John" lastName:"Doe"];

// Copy returns same instance here, since it assumes immutability.
MyPerson *cloned = [person copy];

// this creates a new MyPerson instance, but still read only. We'll see how to change that later.
MyPerson *mutableClone = [person mutableCopy];

[person isEqual:mutableClone]; // => true
[NSSet setWithArray:@[person, mutableClone]]; // => set of 1 person

// get a nice description for free
[person description]; // => <MyPerson 0xdeadbeef firstName=John lastName=Doe>
// even in LLDB:
// > po person => <MyPerson 0xdeadbeef firstName=John lastName=Doe>
```

Want `-[mutableCopy]` to use a different, actual, mutable class? Not a problem!

```objc
@class MyMutablePerson;

@implementation MyPerson

- (Class)JKV_mutableClass
{
    return [MyMutablePerson class];
}

@end

@interface MyMutablePerson : MyPerson
@property (strong, nonatomic, readwrite) NSString *firstName;
@property (strong, nonatomic, readwrite) NSString *lastName;
@end

@implementation MyMutablePerson

@synthesize firstName;
@synthesize lastName;

- (BOOL)JKV_isMutable
{
    return YES; // to hint to JKVValue that this concrete class is mutable.
}

- (Class)JKV_immutableClass
{
    return [MyPerson class]; // tells JKVValue which class to create for the immutable variant
}

@end
```

Now you can switch between mutable and immutable variants like NSArray or
NSDictionary:

```objc
// assuming MyPerson *person from above
MyMutablePerson *mutablePerson = [person mutableCopy];
MyPerson *immutablePerson = [mutablePerson copy];
```

If you prefer to use use only mutable objects, `JKVMutableValue` is provided as
a convinence, it simply overrides JKVValue's `-[JVK_isMutable]` to be `YES`
instead of its default of `NO`.

It's worth noting that copy/mutableCopy is called on all properties if they
support NSCopying or NSMutableCopying correspondingly.

Basic Diffing
-------------

You have a lot of fields for two value objects and you want to know why
`-[isEqual:]` is failing?  Use `-[differenceToObject:]`:

```objc
MyPerson *person1 = [MyPerson new];
person1.firstName = @"John";
MyPerson *person2 = [MyPerson new];
person2.firstName = @"James";
[person1 differenceToObject:person2]; // => @{@"firstName": @[@"John", @"James"};
[person1 differenceToObject:@1]; // => @{@"class": @[[MyPerson class], NSClassFromString(@"__CFNSNumber")}
```

Testing
-------

This library comes with a factory class, `JKVFactory`, to produce pre-built
value objects easily.  It's not explicitly tied to `JKVValue` or
`JKVMutableValue`, but is useful pattern for drying up the boilerplate of
generating pre-populated value objects.

For the simpliest case of having a value object where non of its properties are
zero:

```objc
JKVFactory *personFactory = [JKVFactory factoryForClass:[MyPerson class]]
MyPerson *person = [personFactory object];
```

If you want more customization, it's recommended to inherit from `JKVFactory`
with a custom `-[init]` method:

```objc
@interface MyPersonFactory : JKVFactory
@end

@implementation MyPersonFactory

- (id)init
{
    return [super initWithClass:[MyPerson class] properties:@{@"firstName": @"John"}];
}

@end

// shortcut to [[MyPersonFactory new] object]
MyPerson *person = [MyPersonFactory buildObject];
```

Want a special object with custom properties?

```objc
[MyPersonFactory buildObjectWithProperties:@{@"firstName": @"James"}];
```

Need to nil out a property? Use `[NSNull null]`:

```objc
[MyPersonFactory buildObjectWithProperties:@{@"lastName": [NSNull null]}];
```


Descriptions for Objective-C Containers
=======================================

JKVValue provides nice descriptions to ``NSArrays``, ``NSDictionaries``, and
``NSSets`` properties. It doesn't override the default implementations on those
classes by default. You can tell JKVValue to override them:

```objc
[JKVObjectPrinter swizzleContainers];
// you can undo the swizzling using [JKVObjectPrinter unswizzleContainers].
```

Gotchas
=======

Potential strangeness due to implementation details:

 - Properties that are not backed by an instance variable are ignored.
 - Property assignment is done using KVC, which allows mutation of properties despite being marked as readonly. A private `-[init]` constructor is used by JKVValue to create the initial object.
 - weak properties are not used for equality (or hashing) since their life can be lost to a value object at any time.
 - weak properties are assigned through copying, and are not copied (a copied weak would just be released immediately).
 - weak properties are correctly encoded and decoded as conditional objects.
 - Due to the Objective-C Runtime, weak readonly properties behave like strong properties for JKVValues.
 - If you use the immutable-mutable pattern, you cannot have your constructor use the ivars directly, since the mutable version is overwriting them with its own.

