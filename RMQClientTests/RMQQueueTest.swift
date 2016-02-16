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
//    func testPublishOnDefaultExchange() {
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
//        let publish = AMQProtocolBasicPublish(
//            reserved1: AMQShort(0),
//            exchange: AMQShortstr(""),
//            routingKey: AMQShortstr(""),
//            mandatory: AMQBit(0),
//            immediate: AMQBit(0)
//        )
//
//        queue.publish("my great message")
//        transport.assertClientSendsMethod(publish, channelID: 42)
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
//            .serverSendsContentHeader()
//
//        XCTAssertEqual("my great message", queue.pop().content)
//    }

}
