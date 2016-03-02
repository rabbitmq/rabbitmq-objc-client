import XCTest

class FramesetRoutingTest: XCTestCase {
    
    func testBasicDeliverGetsSentToAppropriateChannel() {
        let transport = ControlledInteractionTransport()
        let allocator = ChannelSpyAllocator()
        let connection = RMQConnection(
            transport: transport,
            channelAllocator: allocator,
            user: "foo",
            password: "bar",
            vhost: "",
            channelMax: 10,
            frameMax: 5000,
            heartbeat: 10
        )
        connection.start()
        transport.handshake()

        connection.createChannel()
        transport.serverSendsPayload(MethodFixtures.channelOpenOk(), channelID: 1)

        let ch2 = connection.createChannel() as! ChannelSpy
        transport.serverSendsPayload(MethodFixtures.channelOpenOk(), channelID: 2)

        connection.createChannel()
        transport.serverSendsPayload(MethodFixtures.channelOpenOk(), channelID: 3)

        let body1 = AMQContentBody(data: "a great ".dataUsingEncoding(NSUTF8StringEncoding)!)
        let body2 = AMQContentBody(data: "message".dataUsingEncoding(NSUTF8StringEncoding)!)
        let header = AMQContentHeader(classID: 123, bodySize: body1.length + body2.length, properties: [])
        transport
            .serverSendsPayload(MethodFixtures.basicDeliver(), channelID: 2)
            .serverSendsPayload(header, channelID: 2)
            .serverSendsPayload(body1, channelID: 2)
            .serverSendsPayload(body2, channelID: 2)

        let expectedMethod = AMQProtocolBasicDeliver(
            consumerTag: AMQShortstr(""),
            deliveryTag: AMQLonglong(0),
            options: AMQProtocolBasicDeliverOptions.NoOptions,
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("")
        )

        let expectedFrameset = AMQFrameset(
            channelID: 2,
            method: expectedMethod,
            contentHeader: header,
            contentBodies: [body1, body2]
        )

        XCTAssertEqual(expectedFrameset, ch2.lastReceivedFrameset!)
    }
    
}
