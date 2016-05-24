@objc class TransportDelegateSpy: NSObject, RMQTransportDelegate {
    var lastDisconnectError: NSError?
    var disconnectCalled = false

    func transport(transport: RMQTransport!, failedToWriteWithError error: NSError!) {
        print("failed to write")
    }

    func transport(transport: RMQTransport!, disconnectedWithError error: NSError!) {
        disconnectCalled = true
        lastDisconnectError = error
    }
}