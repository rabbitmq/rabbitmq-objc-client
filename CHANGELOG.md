# RabbitMQ Objective-C and Swift Client Changelog

## [0.12.0] - 2022-04-24

 ### Fixed

  * Eliminated a memory leak in environments where connections were closed and opened
    dynamically during application operations.

    Contributed by @BarryDuggan and @michaelklishin.

    GitHub issue: [#198](https://github.com/rabbitmq/rabbitmq-objc-client/pull/198)
