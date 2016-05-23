@objc class TransportDelegateSpy: NSObject, RMQTransportDelegate {
    var lastDisconnectError: NSError?

    func transport(transport: RMQTransport!, failedToWriteWithError error: NSError!) {
    }

    func transport(transport: RMQTransport!, disconnectedWithError error: NSError!) {
        lastDisconnectError = error
    }
}