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

## License

This package, the RabbitMQ Objective-C client library, is triple-licensed
under the Mozilla Public License 1.1 ("MPL"), the GNU General Public License
version 2 ("GPL") and the Apache License version 2 ("ASL").
