@objc class TransportDelegateSpy: NSObject, RMQTransportDelegate {
    var lastDisconnectError = NSError(
        domain: RMQErrorDomain,
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "no error yet"]
    )
    func transport(transport: RMQTransport!, failedToWriteWithError error: NSError!) {

    }

    func transport(transport: RMQTransport!, disconnectedWithError error: NSError!) {
        lastDisconnectError = error
    }
}