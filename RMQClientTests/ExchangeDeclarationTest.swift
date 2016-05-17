import XCTest

class ExchangeDeclarationTest: XCTestCase {

    func testExchangeDeclareSendsAnExchangeDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())
        ch.activateWithDelegate(nil)

        ch.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testFanoutDeclaresAFanout() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())

        ch.activateWithDelegate(nil)

        ch.fanout("my-exchange", options: [.Durable, .AutoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "fanout", options: [.Durable, .AutoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testDirectDeclaresADirectExchange() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())

        ch.activateWithDelegate(nil)

        ch.direct("my-exchange", options: [.Durable, .AutoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "direct", options: [.Durable, .AutoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testTopicDeclaresATopicExchange() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())

        ch.activateWithDelegate(nil)

        ch.topic("my-exchange", options: [.Durable, .AutoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "topic", options: [.Durable, .AutoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testHeadersDeclaresAHeadersExchange() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())

        ch.activateWithDelegate(nil)

        ch.headers("my-exchange", options: [.Durable, .AutoDelete])

        let expectedMethod = MethodFixtures.exchangeDeclare("my-exchange", type: "headers", options: [.Durable, .AutoDelete])

        XCTAssertEqual(expectedMethod, dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

    func testExchangeTypeMethodsReturnFirstWithSameNameEvenIfDifferentOptionsOrTypes() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(321, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())

        ch.activateWithDelegate(nil)

        let ex1 = ch.topic("my-exchange", options: [.Durable, .AutoDelete])
        let ex2 = ch.fanout("my-exchange")
        let ex3 = ch.direct("my-exchange")
        let ex4 = ch.headers("my-exchange", options: [.Durable])

        XCTAssertEqual(ex1, ex2)
        XCTAssertEqual(ex2, ex3)
        XCTAssertEqual(ex3, ex4)
    }

    func testExchangeDeleteSendsAnExchangeDelete() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(123, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())
        ch.exchangeDelete("my exchange", options: [.IfUnused])
        XCTAssertEqual(MethodFixtures.exchangeDelete("my exchange", options: [.IfUnused]),
                       dispatcher.lastSyncMethod as? RMQExchangeDelete)
    }

    func testExchangeDeclareAfterDeleteSendsAFreshDeclare() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(123, contentBodySize: 100, dispatcher: dispatcher, commandQueue: FakeSerialQueue(), nameGenerator: StubNameGenerator())
        ch.fanout("my exchange")
        ch.exchangeDelete("my exchange", options: [])
        dispatcher.lastSyncMethod = nil
        ch.fanout("my exchange")
        XCTAssertEqual(MethodFixtures.exchangeDeclare("my exchange", type: "fanout", options: []), dispatcher.lastSyncMethod as? RMQExchangeDeclare)
    }

}
