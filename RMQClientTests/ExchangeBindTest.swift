import XCTest

class ExchangeBindTest: XCTestCase {

    func testExchangeBindSendsAnExchangeBind() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue())
        ch.activateWithDelegate(nil)

        ch.exchangeBind("source", destination: "dest", routingKey: "somekey")

        XCTAssertEqual(MethodFixtures.exchangeBind("source", destination: "dest", routingKey: "somekey"),
                       dispatcher.lastSyncMethod as? RMQExchangeBind)
    }

}
