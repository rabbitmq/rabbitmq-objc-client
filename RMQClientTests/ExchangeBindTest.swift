import XCTest

class ExchangeBindTest: XCTestCase {

    func testExchangeBindSendsAnExchangeBind() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.exchangeBind("source", destination: "dest", routingKey: "somekey")

        XCTAssertEqual(MethodFixtures.exchangeBind("source", destination: "dest", routingKey: "somekey"),
                       dispatcher.lastSyncMethod as? RMQExchangeBind)
    }

    func testExchangeUnbindSendsAnExchangeUnbind() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)

        ch.exchangeUnbind("sauce", destination: "dest", routingKey: "yale")

        XCTAssertEqual(MethodFixtures.exchangeUnbind("sauce", destination: "dest", routingKey: "yale"),
                       dispatcher.lastSyncMethod as? RMQExchangeUnbind)
    }

}
