##


## Running Tests

First, run Carthage bootstrap:

```
gmake bootstrap
```

then, with a running RabbitMQ node set up to support [x509 certificate
authentication](https://github.com/rabbitmq/rabbitmq-auth-mechanism-ssl):

```
# use RABBITMQCTL="/path/to/rabbitmqctl"
# Make variables to override RabbitMQ CLI tools to use
gmake test_user RABBITMQCTL="/path/to/rabbitmqctl"

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
