##


## Running Tests

First, run Carthage bootstrap:

```
gmake bootstrap
```

Then start a local RabbitMQ node (any way you please, doesn't have to be from Homebrew or source),
configure it using files under `.travis/etc/` and enable the
[x509 certificate authentication mechanism](https://github.com/rabbitmq/rabbitmq-auth-mechanism-ssl):

    brew install rabbitmq
    cp .travis/etc/* /path/to/etc/rabbitmq/
    rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl

Then restart RabbitMQ.

Now what's left is running a few setup steps:

```
# use RABBITMQCTL="/path/to/rabbitmqctl"
# Make variables to override RabbitMQ CLI tools to use
gmake set_up_test_vhosts RABBITMQCTL="/path/to/rabbitmqctl"
gmake set_up_test_users  RABBITMQCTL="/path/to/rabbitmqctl"

# This will set up the management plugin and configured it to use a short (1s) stats refresh interval.
#
# use RABBITMQCTL="/path/to/rabbitmqctl" and RABBITMQ_PLUGINS="/path/to/rabbitmq-plugins"
# Make variables to override RabbitMQ CLI tools to use
gmake before_build RABBITMQCTL="/path/to/rabbitmqctl" RABBITMQ_PLUGINS="/path/to/rabbitmq-plugins"
```

Finally, to run the tests:


``` bash
# for iOS
gmake tests_ios iOS_VERSION=12.1

# for macOS
gmake tests_macos
```

## SwiftLint

The test suite uses [SwiftLint](https://github.com/realm/SwiftLint) as a build phase.
It must be installed in order for XCode to use it:

``` bash
brew install swiftlint
```

In order to lint from the command line, use

``` bash
swiftlint
```

The lint configuration can be found at [.swiftlint.yml](.swiftlint.yml).
