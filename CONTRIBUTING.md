# Contributing

## Development Workflow

This project uses the most basic development workflow possible:

 * Identify a problem
 * Add a failing test or any other way to reproduce it
 * Fix it
 * Make sure all tests pass
 * Submit a pull request on GitHub explaining **why** the change it necessary
   and how to reproduce it
 * Wait for maintainer's feedback

That's about it.

## Running Tests

### Building Dependencies

Carthage bootstrap will clone and build the dependencies:

```
gmake bootstrap
```

### Run a RabbitMQ Node in Docker

It is possible to run a preconfigured node, including a TLS setup,
in Docker:

``` shell
docker-compose build
docker-compose up
```

This will publish (forward) local ports 5672, 5671, 15672 to the container,
so if there are any local RabbitMQ nodes running they must be stopped first
to avoid port conflicts.  

### Run a Local RabbitMQ Node

There are two sets of tests that can be executed, each with its own
XCode scheme:

 * Unit and integration tests (core tests) use the `RMQClient` scheme
   and can be executed against a RabbitMQ node with stock defaults
   (assuming that certain setup targets are executed, see below)
 * TLS tests use the `RMQClient with TLS tests` scheme and requires
   a RabbitMQ node configured in a particular way

The RabbitMQ node can be installed from Homebrew or by downloading
and extracting a [generic binary build](https://www.rabbitmq.com/install-generic-unix.html).

### Node Configuration for TLS Tests

To configure a node to run the TLS tests, configure the node to use the [certificates and keys](https://www.rabbitmq.com/ssl.html#certificates-and-keys)
under `TestCertificates`. The certificates have a Subject Alternative Name of `localhost`
which makes them not to be dependent on the host they were generated on.

The test suite also requires the [x509 certificate authentication mechanism](https://github.com/rabbitmq/rabbitmq-auth-mechanism-ssl)
plugin to be enabled:

``` shell
# target location will vary depending on how RabbitMQ was installed
cp TestCertificates/* /path/to/rabbitmq-home/etc/rabbitmq/
rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl --offline
```

Then restart RabbitMQ.

The following [RabbitMQ configuration file](https://www.rabbitmq.com/configure.html#configuration-files)
is used by CI and can be used as example:

``` ini
auth_mechanisms.1 = PLAIN
auth_mechanisms.2 = AMQPLAIN
auth_mechanisms.3 = EXTERNAL

listeners.ssl.default  = 5671

## These MUST be updated to point to actual tls-gen generated
## certificates and private keys
ssl_options.cacertfile = /path/to/ca_certificate.pem
ssl_options.certfile   = /path/to/server_certificate.pem
ssl_options.keyfile    = /path/to/server_key.pem


ssl_options.versions.1 = tlsv1.2

ssl_options.verify               = verify_peer
ssl_options.fail_if_no_peer_cert = false

ssl_options.honor_cipher_order   = true
ssl_options.honor_ecc_order      = true
ssl_options.client_renegotiation = false
ssl_options.secure_renegotiate   = true

ssl_options.ciphers.1  = ECDHE-ECDSA-AES256-GCM-SHA384
ssl_options.ciphers.2  = ECDHE-RSA-AES256-GCM-SHA384
ssl_options.ciphers.3  = ECDH-ECDSA-AES256-GCM-SHA384
ssl_options.ciphers.4  = ECDH-RSA-AES256-GCM-SHA384
ssl_options.ciphers.5  = DHE-RSA-AES256-GCM-SHA384
ssl_options.ciphers.6  = DHE-DSS-AES256-GCM-SHA384
ssl_options.ciphers.7  = ECDHE-ECDSA-AES128-GCM-SHA256
ssl_options.ciphers.8  = ECDHE-RSA-AES128-GCM-SHA256
ssl_options.ciphers.9  = ECDH-ECDSA-AES128-GCM-SHA256
ssl_options.ciphers.10 = ECDH-RSA-AES128-GCM-SHA256
ssl_options.ciphers.11 = DHE-RSA-AES128-GCM-SHA256
ssl_options.ciphers.12 = DHE-DSS-AES128-GCM-SHA256
```

In case a different set of certificates is desired, it is highly recommended
[using tls-gen](https://github.com/michaelklishin/tls-gen)'s basic profile.

### Node Preconfiguration

To seed the node (pre-create certain [virtual hosts](https://www.rabbitmq.com/vhosts.html), users,
[permissions](https://www.rabbitmq.com/access-control.html)):

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

### Test Targets

To run the core test suite:


``` shell
# runs all tests with iOS and MacOS destinations
gmake tests

# iOS only
gmake tests_ios iOS_VERSION=15.4

# MacOS only
gmake tests_macos

```

or run the tests using the `RMQClient` scheme from XCode.

To run the TLS test suite:


``` shell
# see the
gmake tests_with_tls
```

or run the tests using the `RMQClient with TLS tests` scheme in XCode.

## Linting with SwiftLint

The test suite uses [SwiftLint](https://github.com/realm/SwiftLint) as a build phase.
It must be installed in order for XCode to use it:

``` shell
brew install swiftlint
```

In order to lint from the command line, use

``` shell
swiftlint
```

The lint configuration can be found at [.swiftlint.yml](.swiftlint.yml).
