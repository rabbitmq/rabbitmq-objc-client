import XCTest

@objc class ControlledInteractionTransport: NSObject, RMQTransport {
    var connected = false
    var outboundData: [NSData] = []
    var callbacks: Array<(NSData) -> Void> = []

    func connect(onConnect: () -> Void) {
        connected = true
        onConnect()
    }
    func close(onClose: () -> Void) {
        connected = false
        onClose()
    }
    func write(data: NSData, onComplete complete: () -> Void) throws -> RMQTransport {
        if (!connected) {
            throw TestDoubleTransportError.NotConnected(localizedDescription: "foo")
        }
        outboundData.append(data)
        complete()
        return self
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        callbacks.append(complete)
    }
    func serverRepliesWith(data: NSData) -> ControlledInteractionTransport {
        callbacks.removeAtIndex(0)(data)
        return self
    }
    func clientSends(amqMethod: AMQMethod, channelID: Int) -> ControlledInteractionTransport {
        let actual = outboundData.removeAtIndex(0)
        TestHelper.assertEqualBytes(
            AMQEncoder().encodeMethod(amqMethod, channelID: channelID),
            actual,
            "Didn't send \(amqMethod)\n\nSent: \(actual)"
        )
        return self
    }
    func clientSendsProtocolHeader() -> ControlledInteractionTransport {
        TestHelper.assertEqualBytes(
            AMQProtocolHeader().amqEncoded(),
            outboundData.removeAtIndex(0)
        )
        return self
    }
}