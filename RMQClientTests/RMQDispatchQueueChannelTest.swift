import XCTest

class RMQDispatchQueueChannelTest: XCTestCase {
    
    func testBasicConsumeSendsBasicConsumeMethod() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(1, sender: sender)
        channel.basicConsume("a_queue_name") { message in }
        let expectedMethod = AMQBasicConsume(
            reserved1: AMQShort(0),
            queue: AMQShortstr("a_queue_name"),
            consumerTag: AMQShortstr(""),
            options: AMQBasicConsumeOptions.NoOptions,
            arguments: AMQTable([:])
        )
        let receivedMethod = sender.lastSentMethod! as! AMQBasicConsume
        XCTAssertEqual(expectedMethod, receivedMethod)
    }

    func testBasicConsumeWaitsOnBasicConsumeOk() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(432, sender: sender)
        channel.basicConsume("a_queue_name") { message in }

        XCTAssertEqual("AMQBasicConsumeOk", sender.methodWaitedUpon)
        XCTAssertEqual(432, sender.channelWaitedUpon)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(432, sender: sender)

        var consumedMessage = RMQContentMessage(deliveryInfo: [:], metadata: [:], content: "Not consumed yet")
        channel.basicConsume("somequeue") { message in
            consumedMessage = message as! RMQContentMessage
        }

        let method = MethodFixtures.basicDeliver()
        let header = AMQContentHeader(classID: 2, bodySize: 123, properties: [])
        let body = AMQContentBody(data: "Consumed!".dataUsingEncoding(NSUTF8StringEncoding)!)
        let frameset = AMQFrameset(channelNumber: 432, method: method, contentHeader: header, contentBodies: [body])
        channel.handleFrameset(frameset)

        let expectedMessage = RMQContentMessage(
            deliveryInfo: ["consumer_tag": "foo"],
            metadata: ["foo": "bar"],
            content: "Consumed!"
        )
        XCTAssertEqual(expectedMessage, consumedMessage)
    }
    
}
