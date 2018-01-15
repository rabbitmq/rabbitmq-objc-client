##


## Running Tests

First, run Carthage bootstrap:

```
gmake bootstrap
```

then, with a running RabbitMQ node set up to support [x509 certificate
authentication](https://github.com/rabbitmq/rabbitmq-auth-mechanism-ssl):

```
gmake test_user RABBITMQCTL="/path/to/rabbitmqctl"

# This will set up the management plugin and configured it to use a short (1s) stats refresh interval.
#
# export RMQ_OBJC_CLIENT_RABBITMQCTL="rabbitmqctl" and RMQ_OBJC_CLIENT_PLUGINS="rabbitmq-plugins"
# to avoid using sudo.
bin/before_build
```

Finally, to run the tests:


``` bash
# for iOS
gmake tests_iOS iOS_VERSION=11.2

# for macOS
gmake tests_OSX
```
