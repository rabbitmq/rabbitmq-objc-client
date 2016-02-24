import XCTest

class ControlledInteractionTransportTest: RMQTransportContract {
    var transport = ControlledInteractionTransport()

    override func newTransport() -> RMQTransport {
        return transport
    }

    override func testConnectAndDisconnect() {
        super.testConnectAndDisconnect()
    }

    override func testThrowsWhenWritingButNotConnected() {
        super.testThrowsWhenWritingButNotConnected()
    }

    override func testSendingPreambleStimulatesAConnectionStart() {
        let halfSecond = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(halfSecond, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            transport.serverSendsPayload(MethodFixtures.connectionStart(), channelID: 1)
        }

        super.testSendingPreambleStimulatesAConnectionStart()
    }
}
