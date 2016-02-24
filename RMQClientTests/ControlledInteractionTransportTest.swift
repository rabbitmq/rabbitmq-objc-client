import XCTest

class ControlledInteractionTransportTest: XCTestCase {
    func testObeysContract() {
        let transport = ControlledInteractionTransport()
        let contract = RMQTransportContract(transport)
        
        contract
            .connectAndDisconnect()
            .throwsWhenWritingButNotConnected()

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            transport
                .assertClientSentProtocolHeader()
                .serverSendsPayload(MethodFixtures.connectionStart(), channelID: 1)
        }
        contract.sendingPreambleStimulatesAConnectionStart()
    }
}
