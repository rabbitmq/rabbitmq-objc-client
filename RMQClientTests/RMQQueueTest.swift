import XCTest

class RMQQueueTest: XCTestCase, AMQReplyContext {

    func credentials() -> AMQCredentials {
        return AMQCredentials()
    }

    func testPublishOnDefaultExchange() {
        let transport = ControlledInteractionTransport()
        let connection = RMQConnection(user: "", password: "", vhost: "", transport: transport, idAllocator: RMQChannelIDAllocator())
        transport.connect {}
        
        let ch = connection.createChannel()
        transport.assertClientSentMethod(MethodFixtures.channelOpen(), channelID: 1)
        
        let queue = ch.queue(
            "cool.queue",
            autoDelete: false,
            exclusive: false
        )
        transport.assertClientSentMethod(MethodFixtures.queueDeclare("cool.queue"), channelID: 1)

        queue.publish("my great message")

        let publish = AMQProtocolBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("cool.queue"),
            options: AMQProtocolBasicPublishOptions.NoOptions
        )
        let bodyData = "my great message".dataUsingEncoding(NSUTF8StringEncoding)!

        let persistent = AMQBasicDeliveryMode(2)
        let contentTypeOctetStream = AMQBasicContentType("application/octet-stream")
        let lowPriority = AMQBasicPriority(0)

        let header = AMQContentHeader(
            classID: 60,
            bodySize: bodyData.length,
            properties: [persistent, contentTypeOctetStream, lowPriority]
        )

        let body = AMQContentBody(data: bodyData)

        let publishFrameset = AMQFrameset(
            channelID: 1,
            method: publish,
            contentHeader: header,
            contentBodies: [body]
        )
        transport.assertClientSentFrameset(publishFrameset)
    }

    func testPop() {
        let transport = ControlledInteractionTransport()
        let connection = RMQConnection(user: "", password: "", vhost: "", transport: transport, idAllocator: RMQChannelIDAllocator())
        connection.start()

        transport.handshake()

        let ch = connection.createChannel()
        transport.assertClientSentMethod(MethodFixtures.channelOpen(), channelID: 1)

        let queue = ch.queue(
            "cool.queue",
            autoDelete: false,
            exclusive: false
        )
        transport.assertClientSentMethod(MethodFixtures.queueDeclare("cool.queue"), channelID: 1)

        let get = AMQProtocolBasicGet(
            reserved1: AMQShort(0),
            queue: AMQShortstr("cool.queue"),
            options: AMQProtocolBasicGetOptions.NoOptions
        )
        let getOk = AMQProtocolBasicGetOk(
            deliveryTag: AMQLonglong(1234),
            options: AMQProtocolBasicGetOkOptions.NoOptions,
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("cool.queue"),
            messageCount: AMQLong(0)
        )
        let contentHeader = AMQContentHeader(classID: getOk.classID(), bodySize: 23, properties: [])
        let contentBody = AMQContentBody(data: "message without special chars".dataUsingEncoding(NSUTF8StringEncoding)!)

        let halfSecond = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(halfSecond, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            transport
                .assertClientSentMethod(get, channelID: 1)
                .serverSendsPayload(getOk, channelID: 1)
                .serverSendsPayload(contentHeader, channelID: 1)
                .serverSendsPayload(contentBody, channelID: 1)
        }

        let message = queue.pop()

        XCTAssertEqual("message without special chars", message.content)
    }

}
