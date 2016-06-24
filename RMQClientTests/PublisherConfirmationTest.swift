import XCTest

class PublisherConfirmationTest: XCTestCase {

    func testConfirmSelectSendsConfirmSelectMethod() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.confirmSelect()

        XCTAssertEqual(MethodFixtures.confirmSelect(), dispatcher.lastSyncMethod as? RMQConfirmSelect)
    }

    func testConfirmSelectEnablesConfirmations() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)

        XCTAssertFalse(confirmations.isEnabled())
        ch.confirmSelect()
        XCTAssert(confirmations.isEnabled())
    }

    func testCallbackIsPassedToConfirmationsHandler() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)

        var receivedAcks: Set<NSNumber>?
        var receivedNacks: Set<NSNumber>?
        ch.afterConfirmed { (acks, nacks) in
            receivedAcks = acks
            receivedNacks = nacks
        }

        confirmations.lastReceivedCallback!([1, 2], [3, 4])
        XCTAssertEqual([1, 2], receivedAcks)
        XCTAssertEqual([3, 4], receivedNacks)
    }

    func testEveryPublicationIsCounted() {
        let confirmations = ConfirmationsSpy()
        let ch = ChannelHelper.makeChannel(1, confirmations: confirmations)

        XCTAssertEqual(0, confirmations.publicationCount)
        ch.basicPublish("hi there", routingKey: "", exchange: "", properties: [], options: [])
        XCTAssertEqual(1, confirmations.publicationCount)
    }

    func testServerAcksAreRecordedOnceDequeued() {
        let confirmations = ConfirmationsSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, confirmations: confirmations)

        let ack = MethodFixtures.basicAck(123, options: [.Multiple])
        ch.handleFrameset(RMQFrameset(channelNumber: 1, method: ack))

        XCTAssertNil(confirmations.lastReceivedAck)
        try! dispatcher.step()
        XCTAssertEqual(ack, confirmations.lastReceivedAck)
    }

    func testServerNacksAreRecordedOnceDequeued() {
        let confirmations = ConfirmationsSpy()
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher, confirmations: confirmations)

        let nack = MethodFixtures.basicNack(123, options: [.Multiple])
        ch.handleFrameset(RMQFrameset(channelNumber: 1, method: nack))

        XCTAssertNil(confirmations.lastReceivedNack)
        try! dispatcher.step()
        XCTAssertEqual(nack, confirmations.lastReceivedNack)
    }
    
}
