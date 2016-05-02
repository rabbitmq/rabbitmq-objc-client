import XCTest

class RMQGCDHeartbeatSenderTest: XCTestCase {
    var oneSecond = 1.01

    func makeSender() -> (sender: RMQGCDHeartbeatSender, transport: ControlledInteractionTransport, clock: FakeClock) {
        let transport = ControlledInteractionTransport()
        let clock = FakeClock()
        let sender = RMQGCDHeartbeatSender(transport: transport,
                                           clock: clock)

        return (sender, transport, clock)
    }

    func testSendsHeartbeats() {
        let (sender, transport, clock) = makeSender()
        let beat = RMQHeartbeat().amqEncoded()

        sender.startWithInterval(1)
        defer { sender.stop() }

        clock.advance(oneSecond)
        clock.advance(oneSecond)

        TestHelper.run(1.5)

        XCTAssertEqual([beat, beat], transport.outboundData)
    }

    func testDoesNotBeatIfIntervalNotPassed() {
        let (sender, transport, clock) = makeSender()
        let beat = RMQHeartbeat().amqEncoded()

        sender.startWithInterval(1)
        defer { sender.stop() }

        TestHelper.run(1)

        XCTAssertEqual([], transport.outboundData)
    }

    func testDoesNotBeatIfActivityRecentlySignalled() {
        let (sender, transport, clock) = makeSender()
        let beat = RMQHeartbeat().amqEncoded()

        sender.startWithInterval(1)
        defer { sender.stop() }

        clock.advance(oneSecond)
        clock.advance(oneSecond)
        sender.signalActivity()

        TestHelper.run(1)

        XCTAssertEqual([], transport.outboundData)
    }
}
