tests: tests_iOS tests_OSX

iOS_VERSION := 10.3.1

RABBITMQCTL := /usr/local/sbin/rabbitmqctl

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

licenses:
	bin/add-license rb '#' license-header-ruby.txt codegen/ && \
		bin/add-license m,h,swift '//' license-header.txt RMQClient/ RMQClientTests/ RMQClientIntegrationTests/
