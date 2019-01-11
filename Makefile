tests: tests_iOS tests_MacOS

iOS_VERSION := 12.1

RABBITMQCTL := /usr/local/sbin/rabbitmqctl
RABBITMQ_PLUGINS := /usr/local/sbin/rabbitmq-plugins

tests: tests_iOS tests_macos lint

tests_ios: tests_iOS

tests_macos: tests_MacOS

tests_iOS: test_dependencies
	set -o pipefail && \
		xcodebuild test \
		-project RMQClient.xcodeproj \
		-scheme RMQClient \
		-destination 'platform=iOS Simulator,name=iPhone XR,OS=$(iOS_VERSION)' | \
		xcpretty

tests_MacOS: test_dependencies
	set -o pipefail && \
		xcodebuild test \
		-project RMQClient.xcodeproj \
		-scheme RMQClient \
		-destination 'platform=OS X,arch=x86_64' | \
		xcpretty

test_dependencies: bootstrap
	gem list -i xcpretty || gem install xcpretty

bootstrap:
	bin/bootstrap-if-needed

set_up_test_vhosts:
	$(RABBITMQCTL) add_vhost "vhost/with/a/few/slashes"

set_up_test_users:
	$(RABBITMQCTL) add_user "O=client,CN=guest" bunnies
	$(RABBITMQCTL) set_permissions "O=client,CN=guest" ".*" ".*" ".*"


before_build:
	$(RABBITMQ_PLUGINS) enable rabbitmq_management
	$(RABBITMQCTL) eval 'supervisor2:terminate_child(rabbit_mgmt_sup_sup, rabbit_mgmt_sup), application:set_env(rabbitmq_management,       sample_retention_policies, [{global, [{605, 1}]}, {basic, [{605, 1}]}, {detailed, [{10, 1}]}]), rabbit_mgmt_sup_sup:start_child().'
	$(RABBITMQCTL) eval 'supervisor2:terminate_child(rabbit_mgmt_agent_sup_sup, rabbit_mgmt_agent_sup), application:set_env(rabbitmq_management_agent, sample_retention_policies, [{global, [{605, 1}]}, {basic, [{605, 1}]}, {detailed, [{10, 1}]}]), rabbit_mgmt_agent_sup_sup:start_child().'

lint:
	swiftlint

licenses:
	bin/add-license rb '#' license-header-ruby.txt codegen/ && \
		bin/add-license m,h,swift '//' license-header.txt RMQClient/ RMQClientTests/ RMQClientIntegrationTests/
