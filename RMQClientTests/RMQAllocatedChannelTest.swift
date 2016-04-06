import XCTest

class RMQAllocatedChannelTest: XCTestCase {

    func testObeysContract() {
        let sender = SenderSpy()
        let channel = RMQAllocatedChannel(1, sender: sender)
        let contract = RMQChannelContract(channel)

        contract.check()
    }

    func testDeclaringAQueueSendsAQueueDeclare() {
        let sender = SenderSpy()
        let channel = RMQAllocatedChannel(1, sender: sender)

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
        let channel = RMQAllocatedChannel(678, sender: sender)

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
        let channel = RMQAllocatedChannel(876, sender: sender)

        XCTAssertEqual(incomingMethod, channel.queueDeclare("madeleine", options: [.AutoDelete, .Exclusive]))
    }
    
    func testBasicConsumeSendsBasicConsumeMethod() {
        let sender = SenderSpy.waitingUpon(AMQBasicConsumeOk(consumerTag: AMQShortstr("taggy")), channelNumber: 1)
        let channel = RMQAllocatedChannel(1, sender: sender)

        try! channel.basicConsume("a_queue_name", options: [.NoAck]) { message in }
        let expectedMethod = AMQBasicConsume(
            reserved1: AMQShort(0),
            queue: AMQShortstr("a_queue_name"),
            consumerTag: AMQShortstr(""),
            options: [.NoAck],
            arguments: AMQTable([:])
        )
        let receivedMethod = sender.lastSentMethod! as! AMQBasicConsume
        XCTAssertEqual(expectedMethod, receivedMethod)
    }

    func testBasicConsumeWaitsOnBasicConsumeOk() {
        let sender = SenderSpy()
        let channel = RMQAllocatedChannel(432, sender: sender)
        sender.lastWaitedUponFrameset = AMQFrameset(channelNumber: 432, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("taggy")))
        try! channel.basicConsume("a_queue_name", options: []) { message in }

        XCTAssertEqual("AMQBasicConsumeOk", sender.methodWaitedUpon)
        XCTAssertEqual(432, sender.channelWaitedUpon)
    }

    func testBasicConsumeCallsCallbackWhenMessageIsDelivered() {
        let sender = SenderSpy()
        let channel = RMQAllocatedChannel(432, sender: sender)
        sender.lastWaitedUponFrameset = AMQFrameset(channelNumber: 432, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("foo")))

        var consumedMessage = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "Not consumed yet")
        try! channel.basicConsume("somequeue", options: []) { message in
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

    func testBasicConsumeFailureThrows() {
        let sender = SenderSpy()
        sender.throwFromSendFramesetWaitUpon = true
        let channel = RMQAllocatedChannel(432, sender: sender)

        do {
            try channel.basicConsume("somequeue", options: []) { message in }
        }
        catch let e as NSError {
            XCTAssertEqual("RMQClientTests.SenderSpyError", e.domain)
        }
        catch {
            XCTFail("Wrong error")
        }
    }

    func testBasicConsumeDoesNotCallbackIfConsumeOkFails() {
        let sender = SenderSpy()
        sender.throwFromSendFramesetWaitUpon = true
        let channel = RMQAllocatedChannel(432, sender: sender)

        var called = false
        let _ = try? channel.basicConsume("somequeue", options: []) { message in
            called = true
        }

        let deliverMethod = MethodFixtures.basicDeliver(consumerTag: "foo", deliveryTag: 123)
        let header = AMQContentHeader(classID: deliverMethod.classID(), bodySize: 123, properties: [])
        let body = AMQContentBody(data: "Should not be consumed!".dataUsingEncoding(NSUTF8StringEncoding)!)
        let incomingDeliver = AMQFrameset(channelNumber: 432, method: deliverMethod, contentHeader: header, contentBodies: [body])
        channel.handleFrameset(incomingDeliver)

        XCTAssertFalse(called)
    }

    func testMultipleConsumersOnSameQueueReceiveMessages() {
        let sender = SenderSpy()
        let channel = RMQAllocatedChannel(999, sender: sender)

        var consumedMessage1 = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "Not consumed yet")
        var consumedMessage2 = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "Not consumed yet")

        let consumeOk1 = AMQFrameset(channelNumber: 999, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("servertag1")))
        let consumeOk2 = AMQFrameset(channelNumber: 999, method: AMQBasicConsumeOk(consumerTag: AMQShortstr("servertag2")))

        sender.lastWaitedUponFrameset = consumeOk1
        try! channel.basicConsume("sameq", options: []) { message in
            consumedMessage1 = message as! RMQContentMessage
        }

        sender.lastWaitedUponFrameset = consumeOk2
        try! channel.basicConsume("sameq", options: []) { message in
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

    func testBasicQosSendsBasicQosGlobal() {
        let sender = SenderSpy.waitingUpon(AMQBasicQosOk(), channelNumber: 999)
        let channel = RMQAllocatedChannel(999, sender: sender)

        try! channel.basicQos(32, global: true)

        let expectedMethod = MethodFixtures.basicQos(32, options: [.Global])
        let actualMethod = sender.lastSentMethod as! AMQBasicQos
        XCTAssertEqual(expectedMethod, actualMethod)
    }

    func testBasicQosSendsBasicQosNonGlobal() {
        let sender = SenderSpy.waitingUpon(AMQBasicQosOk(), channelNumber: 999)
        let channel = RMQAllocatedChannel(999, sender: sender)

        try! channel.basicQos(64, global: false)

        let expectedMethod = MethodFixtures.basicQos(64, options: [])
        let actualMethod = sender.lastSentMethod as! AMQBasicQos
        XCTAssertEqual(expectedMethod, actualMethod)
    }

    func testBasicQosWaitsOnBasicQosOk() {
        let sender = SenderSpy.waitingUpon(AMQBasicQosOk(), channelNumber: 999)
        let channel = RMQAllocatedChannel(999, sender: sender)

        try! channel.basicQos(64, global: false)

        XCTAssertEqual("AMQBasicQosOk", sender.methodWaitedUpon)
    }

    func testBasicQosReturnsBasicQosOk() {
        let sender = SenderSpy.waitingUpon(AMQBasicQosOk(), channelNumber:  999)
        let channel = RMQAllocatedChannel(999, sender: sender)

        XCTAssertEqual(AMQBasicQosOk(), try! channel.basicQos(123, global: false))
    }

    func testBasicQosSetsChannelPrefetchSettings() {
        let sender = SenderSpy.waitingUpon(AMQBasicQosOk(), channelNumber: 999)
        let channel = RMQAllocatedChannel(999, sender: sender)

        XCTAssertEqual(0, channel.prefetchCount)
        XCTAssertFalse(channel.prefetchGlobal)

        try! channel.basicQos(123, global: true)

        XCTAssertEqual(123, channel.prefetchCount)
        XCTAssert(channel.prefetchGlobal)

        try! channel.basicQos(321, global: false)

        XCTAssertEqual(321, channel.prefetchCount)
        XCTAssertFalse(channel.prefetchGlobal)
    }

    func testNoPrefetchSettingChangeWhenSenderThrows() {
        let sender = SenderSpy()
        sender.throwFromSendFramesetWaitUpon = true
        let channel = RMQAllocatedChannel(999, sender: sender)

        if let qosOk = try? channel.basicQos(123, global: true) {
            XCTFail("basicQos didn't throw, returned \(qosOk).")
        } else {
            XCTAssertEqual(0, channel.prefetchCount)
            XCTAssertFalse(channel.prefetchGlobal)
        }
    }
}
