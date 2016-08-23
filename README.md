# RabbitMQ Objective-C and Swift client

[![Build Status](https://travis-ci.org/rabbitmq/rabbitmq-objc-client.svg?branch=master)](https://travis-ci.org/rabbitmq/rabbitmq-objc-client)

A RabbitMQ client, largely influenced by [Bunny](https://github.com/ruby-amqp/bunny).

Test-driven from Swift and implemented in Objective-C, to avoid burdening Objective-C developers with Swift baggage.

## Currently implemented

- [x] Publish and consume messages as strings
- [x] Manipulate queues, exchanges, bindings and consumers.
- [x] Asynchronous API using GCD queues under the hood (a delegate receives errors on a configurable GCD queue).
- [x] Configurable recovery from network interruption and connection-level exceptions
- [x] TLS support
- [x] Client heartbeats
- [x] Carthage support
- [x] CocoaPods support
- [x] iOS support
- [ ] [OSX support](https://github.com/rabbitmq/rabbitmq-objc-client/issues/55)
- [x] PKCS12 client certificates using the [TLS auth mechanism plugin](https://github.com/rabbitmq/rabbitmq-auth-mechanism-ssl)
- [ ] [PKCS12 client certificates using chained CAs](https://github.com/rabbitmq/rabbitmq-objc-client/issues/74)
- [x] [Publisher confirmations](https://github.com/rabbitmq/rabbitmq-objc-client/issues/68)
- [x] [Publish and consume messages as data](https://github.com/rabbitmq/rabbitmq-objc-client/issues/46)
- [ ] [Connection closure when broker doesn't send heartbeats fast enough](https://github.com/rabbitmq/rabbitmq-objc-client/issues/41)
- [x] [Customisable consumer hooks](https://github.com/rabbitmq/rabbitmq-objc-client/issues/71)
- [ ] [basic.return support](https://github.com/rabbitmq/rabbitmq-objc-client/issues/72)
- [ ] [Transaction support](https://github.com/rabbitmq/rabbitmq-objc-client/issues/73)

## Installation with [Carthage](https://github.com/Carthage/Carthage)

1. Create a Cartfile with the following line:

   ```
   github "rabbitmq/rabbitmq-objc-client" ~> 0.10.0
   ```

   Run carthage, for example in a new project:

   ```
   carthage bootstrap --platform iOS
   ```
1. In your Xcode project, in the **Build Phases** section of your target, open up **Link
Binary With Libraries**. Now drag `Carthage/Build/iOS/RMQClient.framework` into
this list.
1. If you don't already have one, click the '+' icon under **Build Phases** to add a
**Copy Files** phase.
1. Under **Destination**, choose **Frameworks**.
1. Click the '+' and add RMQClient.framework. Ensure **Code Sign On Copy** is checked.

## Installation with [CocoaPods](https://cocoapods.org/)

1. Add the following to your Podfile:

   ```
   pod 'RMQClient', '~> 0.10.0'
   ```
   We recommend adding `use_frameworks!` to enable modular imports (Objective-C only).
1. Run `pod install`.
1. Open your project with `open MyProject.xcworkspace`.

**Objective-C users:** importing with `@import RMQClient;` currently produces an error in Xcode (Could not build module 'RMQClient'), but this should not prevent code from compiling and running. Using crocodile imports avoids this Xcode bug: `#import <RMQClient/RMQClient.h>`.


## Documentation

 * [Several RabbitMQ tutorials](http://www.rabbitmq.com/getstarted.html) are provided for
   this client library.

## (Basic) Usage Example

1. Instantiate an `RMQConnection`:

   ```swift
   let delegate = RMQConnectionDelegateLogger() // implement RMQConnectionDelegate yourself to react to errors
   let conn = RMQConnection(uri: "amqp://guest:guest@localhost:5672", delegate: delegate)
   ```
1. Connect:

   ```swift
   conn.start()
   ```
1. Create a channel:

   ```swift
   let ch = conn.createChannel()
   ```
1. Use the channel:

   ```swift
   let q = ch.queue("myqueue")
   q.subscribe { m in
      print("Received: \(m.body)")
   }
   q.publish("foo".dataUsingEncoding(NSUTF8StringEncoding)!)
   ```

1. Close the connection when done:

   ```
   conn.close()
   ```

See [the tutorials](http://www.rabbitmq.com/tutorials/tutorial-one-objectivec.html) for more detailed instructions.

## Running Tests

First make sure you have `xctool` installed:

    brew install xctool

Then start a local RabbitMQ node (any way you please, doesn't have to be from Homebrew or source),
configure it using files under `.travis/etc/`, for example:

    brew install rabbitmq
    cp .travis/etc/* /usr/local/etc/rabbitmq/
    /usr/local/sbin/rabbitmq-plugins enable --offline rabbitmq_auth_mechanism_ssl
    brew services start rabbitmq

Then run a few setup steps:

    bin/bootstrap-if-needed
    /usr/local/sbin/rabbitmqctl add_user "O=client,CN=guest" bunnies
    /usr/local/sbin/rabbitmqctl -p / set_permissions "O=client,CN=guest" ".*" ".*" ".*"

Finally, run the test suite:

    xctool -project RMQClient.xcodeproj -sdk iphonesimulator -scheme RMQClient test


## License

This package, the RabbitMQ Objective-C client library, is
dual-licensed under the Mozilla Public License 1.1 ("MPL") and the
Apache License version 2 ("ASL").
