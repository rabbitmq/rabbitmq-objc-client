tests: tests_iOS tests_OSX

iOS_VERSION := 10.2

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
	/usr/local/sbin/rabbitmqctl add_user "O=client,CN=guest" bunnies && \
	  /usr/local/sbin/rabbitmqctl set_permissions "O=client,CN=guest" ".*" ".*" ".*"

