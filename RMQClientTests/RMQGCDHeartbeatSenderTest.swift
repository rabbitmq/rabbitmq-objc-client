import XCTest

class RMQGCDHeartbeatSenderTest: XCTestCase {
    func makeSender() -> (sender: RMQGCDHeartbeatSender, transport: ControlledInteractionTransport, clock: FakeClock) {
        let transport = ControlledInteractionTransport()
        let clock = FakeClock()
        let sender = RMQGCDHeartbeatSender(transport: transport,
                                           clock: clock)

        return (sender, transport, clock)
    }

    func testSendsHeartbeatsRegularly() {
        let (sender, transport, clock) = makeSender()
        let beat = RMQHeartbeat().amqEncoded()

        let handler = sender.startWithInterval(1)
        sender.stop() // don't let scheduled runs interfere with test runs

        clock.advance(1.01)
        handler()
        clock.advance(1)
        handler()

        XCTAssertEqual([beat, beat], transport.outboundData)
    }

    func testDoesNotBeatIfIntervalNotPassed() {
        let (sender, transport, clock) = makeSender()

        let handler = sender.startWithInterval(1)
        sender.stop()

        clock.advance(1)
        handler()

        XCTAssertEqual([], transport.outboundData)
    }

    func testDoesNotBeatIfActivityRecentlySignalled() {
        let (sender, transport, clock) = makeSender()

        let handler = sender.startWithInterval(1)
        sender.stop()

        clock.advance(1.01)
        sender.signalActivity()
        handler()

        XCTAssertEqual([], transport.outboundData)
    }

    func testCanBeStoppedAndStartedWithoutOverResumeException() {
        let (sender, _, _) = makeSender()

        sender.startWithInterval(0.01)
        sender.stop()
        sender.startWithInterval(0.01)
    }

    func testCanBeStoppedBeforeBeingStartedWithoutBadAccess() {
        let (sender, _, _) = makeSender()

        sender.stop()
    }
}
