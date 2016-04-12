@objc class ConnectionDelegatePrinter : NSObject, RMQConnectionDelegate {
    func channel(channel: RMQChannel!, error: NSError!) {
        print("Received channel: \(channel) error: \(error)")
    }

    func connection(connection: RMQConnection!, failedToConnectWithError error: NSError!) {
        print("Received connection: \(connection) failedToConnectWithError: \(error)")
    }

    func connection(connection: RMQConnection!, failedToOpenChannel channel: RMQChannel!, error: NSError!) {
        print("Received connection: \(connection) failedToOpenChannel: \(channel) error: \(error)")
    }

    func connection(connection: RMQConnection!, failedToWriteWithError error: NSError!) {
        print("Received connection: \(connection) failedToWriteWithError: \(error)")
    }

    func connection(connection: RMQConnection!, disconnectedWithError error: NSError!) {
        print("Received connection: \(connection) disconnectedWithError: \(error)")
    }
}