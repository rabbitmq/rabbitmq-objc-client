import XCTest

class RMQExchangeTest: XCTestCase {

    func testPublishCallsPublishOnChannel() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "", channel: ch)
        ex.publish("foo", routingKey: "my.q")

        XCTAssertEqual("foo", ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", ch.lastReceivedBasicPublishExchange)
    }

    func testPublishWithoutRoutingKeyUsesEmptyString() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "", channel: ch)
        ex.publish("foo")

        XCTAssertEqual("foo", ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("", ch.lastReceivedBasicPublishExchange)
    }

    func testPublishWithPersistence() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "some-ex", channel: ch)
        ex.publish("foo", routingKey: "my.q", persistent: true)

        XCTAssertEqual("foo", ch.lastReceivedBasicPublishMessage)
        XCTAssertEqual("my.q", ch.lastReceivedBasicPublishRoutingKey)
        XCTAssertEqual("some-ex", ch.lastReceivedBasicPublishExchange)
        XCTAssertEqual(true, ch.lastReceivedBasicPublishPersistent)
    }

    func testDeleteCallsDeleteOnChannel() {
        let ch = ChannelSpy(1)
        let ex = RMQExchange(name: "deletable", channel: ch)
        
        ex.delete()
        XCTAssertEqual("deletable", ch.lastReceivedExchangeDeleteExchangeName)
        XCTAssertEqual([], ch.lastReceivedExchangeDeleteOptions)

        ex.delete([.IfUnused])
        XCTAssertEqual("deletable", ch.lastReceivedExchangeDeleteExchangeName)
        XCTAssertEqual([.IfUnused], ch.lastReceivedExchangeDeleteOptions)
    }

    func testBindCallsBindOnChannel() {
        let ch = ChannelSpy(1)
        let ex1 = RMQExchange(name: "ex1", channel: ch)
        let ex2 = RMQExchange(name: "ex2", channel: ch)

        ex1.bind(ex2)
        XCTAssertEqual("ex1", ch.lastReceivedExchangeBindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeBindSourceName)
        XCTAssertEqual("", ch.lastReceivedExchangeBindRoutingKey)

        ex1.bind(ex2, routingKey: "foo")
        XCTAssertEqual("ex1", ch.lastReceivedExchangeBindDestinationName)
        XCTAssertEqual("ex2", ch.lastReceivedExchangeBindSourceName)
        XCTAssertEqual("foo", ch.lastReceivedExchangeBindRoutingKey)
    }

}
