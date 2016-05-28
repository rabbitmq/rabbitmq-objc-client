# RabbitMQ Objective-C and Swift client

[![Build Status](https://travis-ci.org/rabbitmq/rabbitmq-objc-client.svg?branch=master)](https://travis-ci.org/rabbitmq/rabbitmq-objc-client)

A work-in-progress from-scratch implementation of a RabbitMQ client, largely
influenced by [Bunny](https://github.com/ruby-amqp/bunny).

Currently testing from Swift and implementing in Objective-C, to avoid
burdening Objective-C developers with Swift baggage.

## Installation with [Carthage](https://github.com/Carthage/Carthage)

1. Create a Cartfile with the following line:

   ```
   github "rabbitmq/rabbitmq-objc-client" "master"
   ```

   Replace `"master"` with the release, commit or branch of your choice.

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
double-licensed under the Mozilla Public License 1.1 ("MPL") and the
Apache License version 2 ("ASL").
