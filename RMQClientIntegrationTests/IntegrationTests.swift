import XCTest

// see steps in .travis.yml to set up your system for running these tests
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
        let src = ch.fanout("src", options: [.AutoDelete])
        let dst = ch.fanout("dest", options: [.AutoDelete])
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])

        dst.bind(src)
        q.bind(dst)

        src.publish(messageContent)

        let semaphore = dispatch_semaphore_create(0)
        let expected = RMQMessage(consumerTag: "", deliveryTag: 1, content: messageContent)
        var actual: RMQMessage?
        q.pop { (_, m) in
            actual = m
            dispatch_semaphore_signal(semaphore)
        }

        XCTAssertEqual(0, dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(2)),
                       "Timed out waiting for pop block to execute")
        XCTAssertEqual(expected, actual)
    }

    func testSubscribe() {
        let delegate = RMQConnectionDelegateLogger()
        let tlsOptions = RMQTLSOptions(
            peerName: "localhost",
            verifyPeer: false,
            pkcs12: CertificateFixtures.guestBunniesP12(),
            pkcs12Password: "bunnies"
        )
        let conn = RMQConnection(uri: "amqps://localhost", tlsOptions: tlsOptions, delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        let semaphore = dispatch_semaphore_create(0)
        let ch = conn.createChannel()
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])

        var delivered: RMQMessage?

        q.subscribe([.NoOptions]) { (_, message) in
            delivered = message
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
        let q = ch.queue("", options: [.AutoDelete, .Exclusive])
        let semaphore = dispatch_semaphore_create(0)

        var isRejected = false

        q.subscribe([.NoOptions]) { (_, message) in
            if isRejected {
                dispatch_semaphore_signal(semaphore)
            } else {
                isRejected = true
                ch.reject(message.deliveryTag, options: [.Requeue])
            }
        }

        ch.defaultExchange().publish("my message", routingKey: q.name)

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

        let messageCount = 2000
        let consumingChannel = conn.createChannel()
        let consumingQueue = consumingChannel.queue("", options: [.AutoDelete, .Exclusive])
        let semaphore = dispatch_semaphore_create(0);

        consumingQueue.subscribe { (_, message) in
            set1.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        consumingQueue.subscribe { (_, message) in
            set2.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        consumingQueue.subscribe { (_, message) in
            set3.insert(message.deliveryTag)
            let currentCount: Int = set1.count + set2.count + set3.count
            if currentCount == messageCount {
                dispatch_semaphore_signal(semaphore)
            }
        }

        sleep(1)

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue(consumingQueue.name, options: [.AutoDelete, .Exclusive])

        for _ in 1...messageCount {
            producingQueue.publish("hello")
        }

        XCTAssertEqual(0,
                       dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(50)),
                       "Timed out waiting for messages to arrive on single channel")

        let emptyCount = [set1, set2, set3].reduce(0) { (acc, set) -> Int in
            acc + (set.isEmpty ? 1 : 0)
        }

        XCTAssertLessThan(emptyCount, 2)

        let expected: Set<NSNumber> = Set<NSNumber>().union((1...messageCount).map { NSNumber(integer: $0) })
        XCTAssertEqual(expected, set1.union(set2).union(set3))
    }

    func testConcurrentDeliveryOnDifferentChannels() {
        var counter: Int32 = 0
        let semaphore = dispatch_semaphore_create(0)
        let delegate = RMQConnectionDelegateLogger()
        let channelCount = 600
        let messageCount: Int32 = 600
        let conn = RMQConnection(uri: "amqp://guest:guest@localhost",
                                 channelMax: channelCount + 1, frameMax: 131072, heartbeat: 100, syncTimeout: 60,
                                 delegate: delegate, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
        conn.start()
        defer { conn.blockingClose() }

        let producingChannel = conn.createChannel()
        let producingQueue = producingChannel.queue("some-queue", options: [.AutoDelete, .Exclusive])

        for _ in 1...channelCount {
            let ch = conn.createChannel()
            let q = ch.queue(producingQueue.name, options: [.AutoDelete, .Exclusive])
            q.subscribe { (_, message) in
                OSAtomicIncrement32(&counter)
                if counter == messageCount {
                    dispatch_semaphore_signal(semaphore)
                }
            }
        }

        for _ in 1...messageCount {
            producingQueue.publish("hello")
        }

        XCTAssertEqual(
            0,
            dispatch_semaphore_wait(semaphore, TestHelper.dispatchTimeFromNow(30)),
            "Timed out waiting for messages to arrive on different channels"
        )
    }

    func testClientChannelCloseCausesFutureOperationsToFail() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()

        ch.close()

        XCTAssert(
            TestHelper.pollUntil {
                ch.basicQos(1, global: false)
                return delegate.lastChannelError?.code == RMQError.ChannelClosed.rawValue
            }
        )
    }

    func testServerChannelCloseCausesFutureOperationsToFail() {
        let delegate = ConnectionDelegateSpy()
        let conn = RMQConnection(delegate: delegate)
        conn.start()
        defer { conn.blockingClose() }

        let ch = conn.createChannel()

        causeServerChannelClose(ch)

        XCTAssert(
            TestHelper.pollUntil {
                ch.basicQos(1, global: false)
                return delegate.lastChannelError?.code == RMQError.ChannelClosed.rawValue
            }
        )
    }

    private func causeServerChannelClose(ch: RMQChannel) {
        ch.basicPublish("", routingKey: "a route that can't be found", exchange: "a non-existent exchange", persistent: false)
    }
}
