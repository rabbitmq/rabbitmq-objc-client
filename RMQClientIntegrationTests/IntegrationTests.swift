import XCTest

class IntegrationTests: XCTestCase {
    
    func testPop() {
        let frameMaxRequiringTwoFrames = 4096
        var messageContent = ""
        for _ in 1...(frameMaxRequiringTwoFrames - AMQEmptyFrameSize) {
            messageContent += "a"
        }
        messageContent += "bb"

        let conn = RMQConnection(
            uri: "amqp://guest:guest@localhost",
            channelMax: 65535,
            frameMax: frameMaxRequiringTwoFrames,
            heartbeat: 0,
            syncTimeout: 10,
            delegate: nil
        )
        conn.start()
        defer { conn.close() }

        let ch = try! conn.createChannel()
        let q = ch.queue(generatedQueueName("pop"), options: [.AutoDelete, .Exclusive])

        q.publish(messageContent)

        let message = q.pop() as! RMQContentMessage

        let expected = RMQContentMessage(consumerTag: "", deliveryTag: 1, content: messageContent)
        XCTAssertEqual(expected, message)
    }

    func testSubscribe() {
        let conn = RMQConnection(uri: "amqp://guest:guest@localhost", delegate: nil)
        conn.start()
        defer { conn.close() }

        let ch = try! conn.createChannel()
        let q = ch.queue(generatedQueueName("subscribe"), options: [.AutoDelete, .Exclusive])

        var delivered = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "not delivered yet")

        try! q.subscribe([.NoOptions]) { (message: RMQMessage) in
            delivered = message as! RMQContentMessage
            try! ch.ack(message.deliveryTag)
        }

        q.publish("my message")

        XCTAssert(TestHelper.pollUntil { return delivered.content != "not delivered yet" })

        XCTAssertEqual(1, delivered.deliveryTag)
        XCTAssertEqual("my message", delivered.content)
    }

    func testReject() {
        let conn = RMQConnection(uri: "amqp://guest:guest@localhost", delegate: nil)
        conn.start()
        defer { conn.close() }

        let ch = try! conn.createChannel()
        let q = ch.queue(generatedQueueName("subscribeForReject"), options: [.AutoDelete, .Exclusive])

        var isRejected = false
        var handledReject = false

        try! q.subscribe([.NoOptions]) { (message: RMQMessage) in
            if isRejected {
                handledReject = true
            } else {
                isRejected = true
                try! ch.reject(message.deliveryTag, options: [.Requeue])
            }
        }

        q.publish("my message")

        XCTAssert(TestHelper.pollUntil { handledReject })
    }

    func testMultipleConsumersOnSameChannel() {
        let conn = RMQConnection()
        conn.start()
        defer { conn.close() }

        var set1 = Set<NSNumber>()
        var set2 = Set<NSNumber>()
        var set3 = Set<NSNumber>()

        let consumingChannel = try! conn.createChannel()
        let queueName = generatedQueueName("multiple-same-channel")
        let consumingQueue = consumingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])

        try! consumingQueue.subscribe { (message: RMQMessage) in
            set1.insert(message.deliveryTag)
        }

        try! consumingQueue.subscribe { (message: RMQMessage) in
            set2.insert(message.deliveryTag)
        }

        try! consumingQueue.subscribe { (message: RMQMessage) in
            set3.insert(message.deliveryTag)
        }

        let producingChannel = try! conn.createChannel()
        let producingQueue = producingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])

        for _ in 1...100 {
            producingQueue.publish("hello")
        }

        XCTAssertEqual(3, producingQueue.consumerCount())
        XCTAssert(
            TestHelper.pollUntil { return set1.union(set2).union(set3).count == 100 },
            "Timed out waiting for messages to arrive on single channel"
        )

        XCTAssertFalse(set1.isEmpty)
        XCTAssertFalse(set2.isEmpty)
        XCTAssertFalse(set3.isEmpty)

        let expected: Set<NSNumber> = Set<NSNumber>().union((1...100).map { NSNumber(integer: $0) })
        XCTAssertEqual(expected, set1.union(set2).union(set3))

        XCTAssertEqual(0, producingQueue.messageCount())
    }

    func testConcurrentDeliveryOnDifferentChannels() {
        var counter: Int32 = 0
        var consumingChannels: [RMQChannel] = []
        var consumingQueues: [RMQQueue] = []
        let queueName = generatedQueueName("concurrent-different-channels")
        let conn = RMQConnection()
        conn.start()
        defer { conn.close() }

        for _ in 1...100 {
            let ch = try! conn.createChannel()
            let q = ch.queue(queueName, options: [.AutoDelete, .Exclusive])
            try! q.subscribe { (message: RMQMessage) in
                OSAtomicIncrement32(&counter)
            }
            consumingChannels.append(ch)
            consumingQueues.append(q)
        }

        let producingChannel = try! conn.createChannel()
        let producingQueue = producingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])
        XCTAssertEqual(100, producingQueue.consumerCount())

        for _ in 1...100 {
            producingQueue.publish("hello")
        }

        XCTAssert(
            TestHelper.pollUntil { return counter == 100 },
            "Timed out waiting for messages to arrive on different channels"
        )

        XCTAssertEqual(0, producingQueue.messageCount())
    }

    func generatedQueueName(identifier: String) -> String {
        return "rmqclient.integration-tests.\(identifier)\(NSProcessInfo.processInfo().globallyUniqueString)"
    }
}
