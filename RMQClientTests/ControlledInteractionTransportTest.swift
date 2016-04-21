import XCTest

class ControlledInteractionTransportTest: XCTestCase {
    func testObeysContract() {
        let transport = ControlledInteractionTransport()
        let contract = RMQTransportContract(transport)
        
        contract.connectAndDisconnect()

        dispatch_after(TestHelper.dispatchTimeFromNow(0.05), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            transport
                .assertClientSentProtocolHeader()
                .serverSendsPayload(MethodFixtures.connectionStart(), channelNumber: 1)
        }
        contract.sendingPreambleStimulatesAConnectionStart()
    }
}
