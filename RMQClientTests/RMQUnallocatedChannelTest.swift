import XCTest

class RMQUnallocatedChannelTest: XCTestCase {

    func assertSendsErrorToDelegate(delegate: ConnectionDelegateSpy, _ blockIndex: Int) {
        XCTAssertEqual(RMQError.ChannelUnallocated.rawValue, delegate.lastChannelError?.code)
        XCTAssertEqual("Unallocated channel", delegate.lastChannelError?.localizedDescription,
                       "Didn't get error when running block \(blockIndex)")
    }

    func testSendsErrorToDelegateWhenUsageAttempted() {
        let delegate = ConnectionDelegateSpy()
        let ch = RMQUnallocatedChannel()
        ch.activateWithDelegate(delegate)

        let blocks: [() -> Void] = [
            { ch.ack(1) },
            { ch.afterConfirmed { _ in } },
            { ch.basicConsume("foo", options: []) { _ in } },
            { ch.basicGet("foo", options: []) { _ in } },
            { ch.basicPublish("hi", routingKey: "yo", exchange: "hmm", properties: [], options: []) },
            { ch.basicQos(2, global: false) },
            { ch.blockingWaitOn(RMQConnectionStart.self) },
            { ch.confirmSelect() },
            { ch.defaultExchange() },
            { ch.exchangeDeclare("", type: "", options: []) },
            { ch.exchangeBind("", destination: "", routingKey: "") },
            { ch.exchangeUnbind("", destination: "", routingKey: "") },
            { ch.fanout("") },
            { ch.direct("") },
            { ch.topic("") },
            { ch.headers("") },
            { ch.exchangeDelete("", options: []) },
            { ch.nack(1) },
            { ch.queue("foo") },
            { ch.queueDelete("foo", options: []) },
            { ch.queueBind("", exchange: "", routingKey: "") },
            { ch.queueUnbind("", exchange: "", routingKey: "") },
            { ch.reject(1) },
        ]

        for (index, run) in blocks.enumerate() {
            delegate.lastChannelError = nil
            run()
            assertSendsErrorToDelegate(delegate, index)
        }
    }

    func testCloseMethodsDoNotProduceError() {
        let delegate = ConnectionDelegateSpy()
        let ch = RMQUnallocatedChannel()
        ch.activateWithDelegate(delegate)
        ch.blockingClose()
        XCTAssertNil(delegate.lastChannelError)
    }

}
