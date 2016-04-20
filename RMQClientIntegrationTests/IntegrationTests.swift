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
            delegate: nil,
            delegateQueue: dispatch_get_main_queue()
        )
        conn.start()
        defer { conn.close() }

        let ch = conn.createChannel()
        let q = ch.queue(generatedQueueName("pop"), options: [.AutoDelete, .Exclusive])

        q.publish(messageContent)

        q.pop { (m) in
            let message = m as! RMQContentMessage
            let expected = RMQContentMessage(consumerTag: "", deliveryTag: 1, content: messageContent)
            XCTAssertEqual(expected, message)
        }
    }

    func testSubscribe() {
        let delegate = RMQConnectionDelegateLogger()
        let conn = RMQConnection(uri: "amqp://guest:guest@localhost", delegate: delegate)
        conn.start()
        defer { conn.close() }

        let ch = conn.createChannel()
        let q = ch.queue(generatedQueueName("subscribe"), options: [.AutoDelete, .Exclusive])

        var delivered = RMQContentMessage(consumerTag: "", deliveryTag: 0, content: "not delivered yet")

        q.subscribe([.NoOptions]) { (message: RMQMessage) in
            delivered = message as! RMQContentMessage
            ch.ack(message.deliveryTag)
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

        let ch = conn.createChannel()
        let q = ch.queue(generatedQueueName("subscribeForReject"), options: [.AutoDelete, .Exclusive])

        var isRejected = false
        var handledReject = false

        q.subscribe([.NoOptions]) { (message: RMQMessage) in
            if isRejected {
                handledReject = true
            } else {
                isRejected = true
                ch.reject(message.deliveryTag, options: [.Requeue])
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

        let consumingChannel = conn.createChannel()
        let queueName = generatedQueueName("multiple-same-channel")
        let consumingQueue = consumingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])

        consumingQueue.subscribe { (message: RMQMessage) in
            set1.insert(message.deliveryTag)
        }

        consumingQueue.subscribe { (message: RMQMessage) in
            set2.insert(message.deliveryTag)
        }

        consumingQueue.subscribe { (message: RMQMessage) in
            set3.insert(message.deliveryTag)
        }

        sleep(2)

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])

        for _ in 1...100 {
            producingQueue.publish("hello")
        }

        XCTAssert(
            TestHelper.pollUntil { return set1.union(set2).union(set3).count == 100 },
            "Timed out waiting for messages to arrive on single channel"
        )

        XCTAssertFalse(set1.isEmpty)
        XCTAssertFalse(set2.isEmpty)
        XCTAssertFalse(set3.isEmpty)

        let expected: Set<NSNumber> = Set<NSNumber>().union((1...100).map { NSNumber(integer: $0) })
        XCTAssertEqual(expected, set1.union(set2).union(set3))
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
            let ch = conn.createChannel()
            let q = ch.queue(queueName, options: [.AutoDelete, .Exclusive])
            q.subscribe { (message: RMQMessage) in
                OSAtomicIncrement32(&counter)
            }
            consumingChannels.append(ch)
            consumingQueues.append(q)
        }

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])

        for _ in 1...100 {
            producingQueue.publish("hello")
        }

        XCTAssert(
            TestHelper.pollUntil { return counter == 100 },
            "Timed out waiting for messages to arrive on different channels"
        )
    }

    func generatedQueueName(identifier: String) -> String {
        return "rmqclient.integration-tests.\(identifier)\(NSProcessInfo.processInfo().globallyUniqueString)"
    }
}
