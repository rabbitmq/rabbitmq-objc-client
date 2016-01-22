import XCTest

class RMQTCPSocketTransportTest: RMQTransportContract {
    override func newTransport() -> RMQTransport {
        return RMQTCPSocketTransport(host: "localhost", port: 5672)
    }
}
