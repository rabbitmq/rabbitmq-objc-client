tests: test_dependencies
	set -o pipefail && \
		xcodebuild test \
		-project RMQClient.xcodeproj \
		-scheme RMQClient \
		-destination 'platform=iOS Simulator,name=iPhone SE,OS=10.0' | \
		xcpretty

test_dependencies:
	gem list -i xcpretty || gem install xcpretty

test_user:
	/usr/local/sbin/rabbitmqctl add_user "O=client,CN=guest" bunnies && \
	  /usr/local/sbin/rabbitmqctl set_permissions "O=client,CN=guest" ".*" ".*" ".*"

