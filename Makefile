tests: tests_iOS tests_OSX

iOS_VERSION := 11.3

RABBITMQCTL := /usr/local/sbin/rabbitmqctl
RABBITMQ_PLUGINS := /usr/local/sbin/rabbitmq-plugins

tests_iOS: test_dependencies
	set -o pipefail && \
		xcodebuild test \
		-project RMQClient.xcodeproj \
		-scheme RMQClient \
		-destination 'platform=iOS Simulator,name=iPhone SE,OS=$(iOS_VERSION)' | \
		xcpretty

tests_OSX: test_dependencies
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

test_user:
	$(RABBITMQCTL) add_user "O=client,CN=guest" bunnies && \
	  $(RABBITMQCTL) set_permissions "O=client,CN=guest" ".*" ".*" ".*"

before_build:
	$(RABBITMQ_PLUGINS) enable rabbitmq_management
	$(RABBITMQCTL) eval 'supervisor2:terminate_child(rabbit_mgmt_sup_sup, rabbit_mgmt_sup), application:set_env(rabbitmq_management,       sample_retention_policies, [{global, [{605, 1}]}, {basic, [{605, 1}]}, {detailed, [{10, 1}]}]), rabbit_mgmt_sup_sup:start_child().'
	$(RABBITMQCTL) eval 'supervisor2:terminate_child(rabbit_mgmt_agent_sup_sup, rabbit_mgmt_agent_sup), application:set_env(rabbitmq_management_agent, sample_retention_policies, [{global, [{605, 1}]}, {basic, [{605, 1}]}, {detailed, [{10, 1}]}]), rabbit_mgmt_agent_sup_sup:start_child().'


licenses:
	bin/add-license rb '#' license-header-ruby.txt codegen/ && \
		bin/add-license m,h,swift '//' license-header.txt RMQClient/ RMQClientTests/ RMQClientIntegrationTests/
