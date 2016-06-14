import XCTest

class QueueBindTest: XCTestCase {

    func testQueueBindSendsAQueueBind() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.activateWithDelegate(nil)

        ch.queueBind("my-q", exchange: "my-exchange", routingKey: "hi")

        let expectedMethod = MethodFixtures.queueBind("my-q", exchangeName: "my-exchange", routingKey: "hi")

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQQueueBind)
    }

    func testQueueUnbindSendsUnbind() {
        let dispatcher = DispatcherSpy()
        let ch = ChannelHelper.makeChannel(1, dispatcher: dispatcher)
        ch.activateWithDelegate(nil)

        ch.queueUnbind("my-q", exchange: "my-exchange", routingKey: "hi")

        let expectedMethod = MethodFixtures.queueUnbind("my-q", exchangeName: "my-exchange", routingKey: "hi")

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQQueueUnbind)
    }

}
