import XCTest

class ExchangeBindTest: XCTestCase {

    func testExchangeBindSendsAnExchangeBind() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())

        ch.exchangeBind("source", destination: "dest", routingKey: "somekey")

        XCTAssertEqual(MethodFixtures.exchangeBind("source", destination: "dest", routingKey: "somekey"),
                       dispatcher.lastSyncMethod as? RMQExchangeBind)
    }

    func testExchangeUnbindSendsAnExchangeUnbind() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())

        ch.exchangeUnbind("sauce", destination: "dest", routingKey: "yale")

        XCTAssertEqual(MethodFixtures.exchangeUnbind("sauce", destination: "dest", routingKey: "yale"),
                       dispatcher.lastSyncMethod as? RMQExchangeUnbind)
    }

}
