@objc class ConnectionDelegateSpy : NSObject, RMQConnectionDelegate {
    var lastChannelError: NSError?
    var lastConnectionError: NSError?
    var lastChannelOpenError: NSError?
    var lastWriteError: NSError?
    var disconnectCalled = false
    var lastDisconnectError: NSError?

    var willStartRecoveryConnection: RMQConnection?
    var startingRecoveryConnection: RMQConnection?
    var recoveredConnection: RMQConnection?

    func channel(channel: RMQChannel!, error: NSError!) {
        lastChannelError = error
    }

    func connection(connection: RMQConnection!, failedToConnectWithError error: NSError!) {
        lastConnectionError = error
    }

    func connection(connection: RMQConnection!, failedToOpenChannel channel: RMQChannel!, error: NSError!) {
        lastChannelOpenError = error
    }

    func connection(connection: RMQConnection!, failedToWriteWithError error: NSError!) {
        lastWriteError = error
    }

    func connection(connection: RMQConnection!, disconnectedWithError error: NSError!) {
        disconnectCalled = true
        lastDisconnectError = error
    }

    func willStartRecoveryWithConnection(connection: RMQConnection!) {
        willStartRecoveryConnection = connection
    }

    func startingRecoveryWithConnection(connection: RMQConnection!) {
        startingRecoveryConnection = connection
    }

    func recoveredConnection(connection: RMQConnection!) {
        recoveredConnection = connection
    }
}