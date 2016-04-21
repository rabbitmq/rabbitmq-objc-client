import XCTest

class IntegrationTests: XCTestCase {
    
    func testPop() {
        let frameMaxRequiringTwoFrames = 4096
        var messageContent = ""
        for _ in 1...(frameMaxRequiringTwoFrames - RMQEmptyFrameSize) {
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
        defer { conn.blockingClose() }

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
        defer { conn.blockingClose() }

        let semaphore = dispatch_semaphore_create(0)
        let ch = conn.createChannel()
        let q = ch.queue(generatedQueueName("subscribe"), options: [.AutoDelete, .Exclusive])

        var delivered: RMQContentMessage?

        q.subscribe([.NoOptions]) { (message: RMQMessage) in
            delivered = message as? RMQContentMessage
            ch.ack(message.deliveryTag)
            dispatch_semaphore_signal(semaphore)
        }

        q.publish("my message")

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for message")

        XCTAssertEqual(1, delivered!.deliveryTag)
        XCTAssertEqual("my message", delivered!.content)
    }

    func testRejectAndRequeueCausesSecondDelivery() {
        let conn = RMQConnection(uri: "amqp://guest:guest@localhost", delegate: nil)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()
        let q = ch.queue(generatedQueueName("subscribeForReject"), options: [.AutoDelete, .Exclusive])
        let semaphore = dispatch_semaphore_create(0)

        var isRejected = false

        q.subscribe([.NoOptions]) { (message: RMQMessage) in
            if isRejected {
                dispatch_semaphore_signal(semaphore)
            } else {
                isRejected = true
                ch.reject(message.deliveryTag, options: [.Requeue])
            }
        }

        q.publish("my message")

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
                       "Timed out waiting for second delivery")
    }

    func testMultipleConsumersOnSameChannel() {
        let conn = RMQConnection()
        conn.start()
        defer { conn.blockingClose() }

        var set1 = Set<NSNumber>()
        var set2 = Set<NSNumber>()
        var set3 = Set<NSNumber>()

        let messageCount = 1000
        let consumingChannel = conn.createChannel()
        let queueName = generatedQueueName("multiple-same-channel")
        let consumingQueue = consumingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])
        let semaphore = dispatch_semaphore_create(0);

        consumingQueue.subscribe { (message: RMQMessage) in
            set1.insert(message.deliveryTag)
            if set1.count + set2.count + set3.count == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        consumingQueue.subscribe { (message: RMQMessage) in
            set2.insert(message.deliveryTag)
            if set1.count + set2.count + set3.count == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        consumingQueue.subscribe { (message: RMQMessage) in
            set3.insert(message.deliveryTag)
            if set1.count + set2.count + set3.count == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])

        for _ in 1...messageCount {
            producingQueue.publish("hello")
        }

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(50)),
                       "Timed out waiting for messages to arrive on single channel")

        XCTAssertFalse(set1.isEmpty)
        XCTAssertFalse(set2.isEmpty)
        XCTAssertFalse(set3.isEmpty)

        let expected: Set<NSNumber> = Set<NSNumber>().union((1...messageCount).map { NSNumber(integer: $0) })
        XCTAssertEqual(expected, set1.union(set2).union(set3))
    }

    func testConcurrentDeliveryOnDifferentChannels() {
        var counter: Int32 = 0
        var consumingChannels: [RMQChannel] = []
        var consumingQueues: [RMQQueue] = []
        let queueName = generatedQueueName("concurrent-different-channels")
        let semaphore = dispatch_semaphore_create(0)
        let delegate = RMQConnectionDelegateLogger()
        let conn = RMQConnection(uri: "amqp://guest:guest@localhost", delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        for _ in 1...100 {
            let ch = conn.createChannel()
            let q = ch.queue(queueName, options: [.AutoDelete, .Exclusive])
            q.subscribe { (message: RMQMessage) in
                OSAtomicIncrement32(&counter)
                if counter == 100 {
                    dispatch_semaphore_signal(semaphore)
                }
            }
            consumingChannels.append(ch)
            consumingQueues.append(q)
        }

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue(queueName, options: [.AutoDelete, .Exclusive])

        for _ in 1...100 {
            producingQueue.publish("hello")
        }

        XCTAssertEqual(
            0,
            dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(10)),
            "Timed out waiting for messages to arrive on different channels"
        )
    }

    func generatedQueueName(identifier: String) -> String {
        return "rmqclient.integration-tests.\(identifier)\(NSProcessInfo.processInfo().globallyUniqueString)"
    }
}
