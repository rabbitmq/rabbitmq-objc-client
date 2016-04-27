import XCTest

class RMQGCDHeartbeatSenderTest: XCTestCase {
    var byOneSecond = 1.01

    func makeSender() -> (sender: RMQGCDHeartbeatSender, transport: ControlledInteractionTransport, q: FakeSerialQueue, waiterFactory: FakeWaiterFactory, clock: FakeClock) {
        let transport = ControlledInteractionTransport()
        let q = FakeSerialQueue()
        let waiterFactory = FakeWaiterFactory()
        let clock = FakeClock()
        let sender = RMQGCDHeartbeatSender(transport: transport,
                                           queue: q,
                                           waiterFactory: waiterFactory,
                                           clock: clock)

        return (sender, transport, q, waiterFactory, clock)
    }

    func testSendsHeartbeats() {
        let (sender, transport, q, _, clock) = makeSender()
        let beat = RMQHeartbeat().amqEncoded()

        sender.startWithInterval(1)

        clock.advance(byOneSecond)
        try! q.step()

        clock.advance(byOneSecond)
        try! q.step()

        sender.stop()

        XCTAssertEqual([beat, beat], transport.outboundData)
    }

    func testSleepsBetweenBeats() {
        let (sender, _, q, waiterFactory, _) = makeSender()

        sender.startWithInterval(0.1)

        try! q.step()
        sender.stop()
        try! q.step()

        XCTAssertEqual(2, waiterFactory.waiters.count)
        XCTAssertTrue(waiterFactory.waiters[0].timesOutCalled)
        XCTAssertTrue(waiterFactory.waiters[1].timesOutCalled)
    }

    func testSignallingActivityExtendsSleepTime() {
        let (sender, transport, q, _, clock) = makeSender()

        sender.startWithInterval(1)

        clock.advance(byOneSecond)
        try! q.step()

        clock.advance(byOneSecond)
        sender.signalActivity()

        try! q.step()

        XCTAssertEqual(1, transport.outboundData.count)

        clock.advance(byOneSecond)
        try! q.step()

        XCTAssertEqual(2, transport.outboundData.count)
    }

    func testStops() {
        let (sender, _, q, _, clock) = makeSender()

        sender.startWithInterval(1)

        clock.advance(byOneSecond)
        try! q.step()

        sender.stop()
        clock.advance(byOneSecond)
        try! q.step()

        XCTAssertEqual(2, q.items.count)
    }

}
