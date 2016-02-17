import XCTest

class RMQQueueTest: XCTestCase, AMQReplyContext {

    func credentials() -> AMQCredentials {
        return AMQCredentials()
    }

//    func testGetEmptyMessage() {
//        let transport = ControlledInteractionTransport()
//        transport.connect {}
//
//        let ch = RMQChannel(42, transport: transport, replyContext: self)
//        let queue = ch.queue(
//            "cool.queue",
//            autoDelete: false,
//            exclusive: false
//        )
//
//        queue.pop()
//
//        let get = AMQProtocolBasicGet(
//            reserved1: AMQShort(0),
//            queue: AMQShortstr("cool.queue"),
//            noAck: AMQBit(1) // TODO: replace with 0 and test acks too
//        )
//        let getOk = AMQProtocolBasicGetOk(
//            deliveryTag: AMQLonglong(1234),
//            redelivered: AMQBit(0),
//            exchange: AMQShortstr(""),
//            routingKey: AMQShortstr(""),
//            messageCount: AMQLong(1)
//        )
//        transport
//            .assertClientSendsMethod(get, channelID: 42)
//            .serverSendsMethod(getOk, channelID: 42)
//            .serverSendsContentHeader(classID: 60, bodySize: 0, properties: [:])
//
//        XCTAssertEqual(RMQEmptyMessage(), queue.pop())
//    }
//
    func testPublishOnDefaultExchange() {
        let transport = ControlledInteractionTransport()
        let connection = RMQConnection(user: "", password: "", vhost: "", transport: transport, idAllocator: RMQChannelIDAllocator())
        transport.connect {}
        
        let ch = connection.createChannel()
        transport.assertClientSendsMethod(MethodFixtures.channelOpen(), channelID: 1)
        
        let queue = ch.queue(
            "cool.queue",
            autoDelete: false,
            exclusive: false
        )

        queue.publish("my great message")

        let publish = AMQProtocolBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr(""),
            options: AMQProtocolBasicPublishOptions.NoOptions
        )
        let bodyData = "my great message".dataUsingEncoding(NSUTF8StringEncoding)!
        let header = AMQContentHeader(classID: 60, bodySize: bodyData.length, properties: [])

        let body = AMQContentBody(data: bodyData)

        let publishFrameset = AMQFrameset(
            channelID: 1,
            method: publish,
            contentHeader: header,
            contentBodies: [body]
        )
        transport
            .assertClientSendsFrameset(publishFrameset)

//        queue.pop()
//
//        let get = AMQProtocolBasicGet(
//            reserved1: AMQShort(0),
//            queue: AMQShortstr("cool.queue"),
//            noAck: AMQBit(1) // TODO: replace with 0 and test acks too
//        )
//        let getOk = AMQProtocolBasicGetOk(
//            deliveryTag: AMQLonglong(1234),
//            redelivered: AMQBit(0),
//            exchange: AMQShortstr(""),
//            routingKey: AMQShortstr(""),
//            messageCount: AMQLong(1)
//        )
//        transport
//            .assertClientSendsMethod(get, channelID: 42)
//            .serverSendsMethod(getOk, channelID: 42)
//            .serverSendsContentHeader()
//
//        XCTAssertEqual("my great message", queue.pop().content)
    }

}
