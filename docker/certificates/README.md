# Test Suite Certificates

The certificates in this directory are used by integration tests (specifically
for [certificate-based authentication](https://github.com/rabbitmq/rabbitmq-auth-mechanism-ssl)).

They are generated using [tls-gen](https://github.com/michaelklishin/tls-gen/)'s basic profile with Common
Name set to`CN=guest, O=client`. The node used for integration tests must have a user with that name,
which is set up using a Make target.

See [CONTRIBUTING.md](https://github.com/rabbitmq/rabbitmq-objc-client/blob/master/CONTRIBUTING.md) for details.
