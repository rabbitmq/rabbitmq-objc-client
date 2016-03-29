import XCTest

class RMQDispatchQueueChannelTest: XCTestCase {

    func testObeysContract() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(1, sender: sender)
        let contract = RMQChannelContract(channel)

        contract.check()
    }

    func testDeclaringAQueueSendsAQueueDeclare() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(1, sender: sender)

        channel.queueDeclare("bagpuss", options: [.AutoDelete, .Exclusive])

        let expectedQueueDeclare = AMQQueueDeclare(
            reserved1: AMQShort(0),
            queue: AMQShortstr("bagpuss"),
            options: [.AutoDelete, .Exclusive],
            arguments: AMQTable([:])
        )
        let actualFrame = sender.sentFramesets.last!
        let actualMethod = actualFrame.method as! AMQQueueDeclare
        XCTAssertEqual(expectedQueueDeclare, actualMethod)
    }

    func testDeclaringAQueueWaitsOnQueueDeclareOk() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(678, sender: sender)

        channel.queueDeclare("fatfurrycatpuss", options: [.AutoDelete, .Exclusive])

        XCTAssertEqual("AMQQueueDeclareOk", sender.methodWaitedUpon)
        XCTAssertEqual(678, sender.channelWaitedUpon)
    }

    func testDeclaringAQueueReturnsTheQueueDeclareOk() {
        let sender = SenderSpy()
        let incomingMethod = AMQQueueDeclareOk(
            queue: AMQShortstr("madeleine"),
            messageCount: AMQLong(123),
            consumerCount: AMQLong(0)
        )
        sender.lastWaitedUponFrameset = AMQFrameset(channelNumber: 876, method: incomingMethod)
        let channel = RMQDispatchQueueChannel(876, sender: sender)

        XCTAssertEqual(incomingMethod, channel.queueDeclare("madeleine", options: [.AutoDelete, .Exclusive]))
    }
    
    func testBasicConsumeSendsBasicConsumeMethod() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(1, sender: sender)
        sender.lastWaitedUponFrameset = AMQFrameset(channelNumber: 1, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("taggy")))
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
        sender.lastWaitedUponFrameset = AMQFrameset(channelNumber: 432, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("taggy")))
        channel.basicConsume("a_queue_name") { message in }

        XCTAssertEqual("AMQBasicConsumeOk", sender.methodWaitedUpon)
        XCTAssertEqual(432, sender.channelWaitedUpon)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(432, sender: sender)
        sender.lastWaitedUponFrameset = AMQFrameset(channelNumber: 432, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("foo")))

        var consumedMessage = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "Not consumed yet")
        channel.basicConsume("somequeue") { message in
            consumedMessage = message as! RMQContentMessage
        }

        let deliverMethod = MethodFixtures.basicDeliver(consumerTag: "foo", deliveryTag: 123)
        let header = AMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let body = AMQContentBody(data: "Consumed!".dataUsingEncoding(NSUTF8StringEncoding)!)
        let incomingDeliver = AMQFrameset(channelNumber: 432, method: deliverMethod, contentHeader: header, contentBodies: [body])
        channel.handleFrameset(incomingDeliver)

        let expectedMessage = RMQContentMessage(consumerTag: "foo", deliveryTag: 123, content: "Consumed!")
        XCTAssertEqual(expectedMessage, consumedMessage)
    }

    func testMultipleConsumersOnSameQueueReceiveMessages() {
        let sender = SenderSpy()
        let channel = RMQDispatchQueueChannel(999, sender: sender)

        var consumedMessage1 = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "Not consumed yet")
        var consumedMessage2 = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "Not consumed yet")

        let consumeOk1 = AMQFrameset(channelNumber: 999, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("servertag1")))
        let consumeOk2 = AMQFrameset(channelNumber: 999, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("servertag2")))

        sender.lastWaitedUponFrameset = consumeOk1
        channel.basicConsume("sameq") { message in
            consumedMessage1 = message as! RMQContentMessage
        }

        sender.lastWaitedUponFrameset = consumeOk2
        channel.basicConsume("sameq") { message in
            consumedMessage2 = message as! RMQContentMessage
        }

        channel.handleFrameset(consumeOk1)
        channel.handleFrameset(consumeOk2)

        let deliverMethod1 = MethodFixtures.basicDeliver(consumerTag: "servertag1", deliveryTag: 1)
        let header1 = AMQContentHeader(classID: deliverMethod1.classID(), bodySize: 123, properties: [])
        let body1 = AMQContentBody(data: "A message for consumer 1".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliver1 = AMQFrameset(channelNumber: 999, method: deliverMethod1, contentHeader: header1, contentBodies: [body1])

        channel.handleFrameset(deliver1)

        let deliverMethod2 = MethodFixtures.basicDeliver(consumerTag: "servertag2", deliveryTag: 1)
        let header2 = AMQContentHeader(classID: deliverMethod2.classID(), bodySize: 123, properties: [])
        let body2 = AMQContentBody(data: "A message for consumer 2".dataUsingEncoding(NSUTF8StringEncoding)!)
        let deliver2 = AMQFrameset(channelNumber: 999, method: deliverMethod2, contentHeader: header2, contentBodies: [body2])

        channel.handleFrameset(deliver2)

        let expectedMessage1 = RMQContentMessage(consumerTag: "servertag1", deliveryTag: 1, content: "A message for consumer 1")
        let expectedMessage2 = RMQContentMessage(consumerTag: "servertag2", deliveryTag: 1, content: "A message for consumer 2")

        XCTAssertEqual(expectedMessage1, consumedMessage1)
        XCTAssertEqual(expectedMessage2, consumedMessage2)
    }
    
}
