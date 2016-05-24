import XCTest

class RMQExchangeTest: XCTestCase {
    let defaultPropertiesWithPersistence = [RMQBasicContentType("application/octet-stream"),
                                            RMQBasicDeliveryMode(2),
                                            RMQBasicPriority(0)]

    func testPublishCallsPublishOnChannel() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "", type: "direct", options: [], channel: ch)
        ex.publish("foo", routingKey: "my.q")

        XCTAssertEqual("foo", ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", ch.lastReceivedBasicPublishExchange)
        XCTAssertEqual(RMQBasicProperties.defaultProperties(), ch.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], ch.lastReceivedBasicPublishOptions)
    }

    func testPublishWithoutRoutingKeyUsesEmptyString() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "", type: "direct", options: [], channel: ch)
        ex.publish("foo")

        XCTAssertEqual("", ch.lastReceivedBasicPublishRoutingKey)
    }

    func testPublishWithPersistence() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "some-ex", type: "direct", options: [], channel: ch)
        ex.publish("foo", routingKey: "my.q", persistent: true)

        XCTAssertEqual("foo", ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("some-ex", ch.lastReceivedBasicPublishExchange)
        XCTAssertEqual(defaultPropertiesWithPersistence, ch.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([], ch.lastReceivedBasicPublishOptions)
    }

    func testPublishWithOptions() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "some-ex", type: "direct", options: [], channel: ch)
        ex.publish("foo", routingKey: "my.q", persistent: false, options: [.Mandatory, .Immediate])

        XCTAssertEqual("foo", ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("some-ex", ch.lastReceivedBasicPublishExchange)
        XCTAssertEqual(RMQBasicProperties.defaultProperties(), ch.lastReceivedBasicPublishProperties!)
        XCTAssertEqual([.Mandatory, .Immediate], ch.lastReceivedBasicPublishOptions)
    }

    func testDeleteCallsDeleteOnChannel() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "deletable", type: "direct", options: [], channel: ch)
        
        ex.delete()
        XCTAssertEqual("deletable", ch.lastReceivedExchangeDeleteExchangeName)
        XCTAssertEqual([], ch.lastReceivedExchangeDeleteOptions)

        ex.delete([.IfUnused])
        XCTAssertEqual("deletable", ch.lastReceivedExchangeDeleteExchangeName)
        XCTAssertEqual([.IfUnused], ch.lastReceivedExchangeDeleteOptions)
    }

    func testBindCallsBindOnChannel() {
        let ch = ChannelSpy(1)
        let ex1 = RMQExchange(name: "ex1", type: "direct", options: [], channel: ch)
        let ex2 = RMQExchange(name: "ex2", type: "direct", options: [], channel: ch)

        ex1.bind(ex2)
        XCTAssertEqual("ex1", ch.lastReceivedExchangeBindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeBindSourceName)
        XCTAssertEqual("", ch.lastReceivedExchangeBindRoutingKey)

        ex1.bind(ex2, routingKey: "foo")
        XCTAssertEqual("ex1", ch.lastReceivedExchangeBindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeBindSourceName)
        XCTAssertEqual("foo", ch.lastReceivedExchangeBindRoutingKey)
    }

    func testUnbindCallsUnbindOnChannel() {
        let ch = ChannelSpy(1)
        let ex1 = RMQExchange(name: "ex1", type: "direct", options: [], channel: ch)
        let ex2 = RMQExchange(name: "ex2", type: "direct", options: [], channel: ch)

        ex1.unbind(ex2)
        XCTAssertEqual("ex1", ch.lastReceivedExchangeUnbindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeUnbindSourceName)
        XCTAssertEqual("", ch.lastReceivedExchangeUnbindRoutingKey)

        ex1.unbind(ex2, routingKey: "foo")
        XCTAssertEqual("ex1", ch.lastReceivedExchangeUnbindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeUnbindSourceName)
        XCTAssertEqual("foo", ch.lastReceivedExchangeUnbindRoutingKey)
    }

}
