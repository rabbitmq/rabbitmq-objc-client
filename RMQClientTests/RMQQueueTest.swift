import XCTest

class RMQQueueTest: XCTestCase {

    func testPublishSendsABasicPublish() {
        let sender = FakeSender()
        let queue = RMQQueue(name: "my.q", channelID: 123, sender: sender)

        queue.publish("my great message 🚮")

        let publish = AMQProtocolBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("my.q"),
            options: AMQProtocolBasicPublishOptions.NoOptions
        )
        let expectedBodyData = "my great message 🚮".dataUsingEncoding(NSUTF8StringEncoding)!

        let persistent = AMQBasicDeliveryMode(2)
        let contentTypeOctetStream = AMQBasicContentType("application/octet-stream")
        let lowPriority = AMQBasicPriority(0)

        let expectedHeader = AMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.length,
            properties: [persistent, contentTypeOctetStream, lowPriority]
        )

        let expectedBody = AMQContentBody(data: expectedBodyData)

        let expectedFrameset = AMQFrameset(
            channelID: 123,
            method: publish,
            contentHeader: expectedHeader,
            contentBodies: [expectedBody]
        )

        XCTAssertEqual(expectedFrameset, sender.lastSentFrameset)
    }

    func testPopSendsAGet() {
        let sender = FakeSender()
        let queue = RMQQueue(name: "great.queue", channelID: 42, sender: sender)

        queue.pop()

        let get = AMQProtocolBasicGet(
            reserved1: AMQShort(0),
            queue: AMQShortstr("great.queue"),
            options: AMQProtocolBasicGetOptions.NoOptions
        )
        let expectedFrameset = AMQFrameset(
            channelID: 42,
            method: get,
            contentHeader: AMQContentHeaderNone(),
            contentBodies: []
        )

        XCTAssertEqual(expectedFrameset, sender.lastSentFrameset)
    }

    func testPopWaitsOnNextGetOk() {
        let sender = FakeSender()
        let queue = RMQQueue(name: "great.queue", channelID: 42, sender: sender)

        queue.pop()

        XCTAssertEqual("AMQProtocolBasicGetOk", sender.methodWaitedUpon)
        XCTAssertEqual(42, sender.channelWaitedUpon)
    }

    func testPopReturnsMessageBasedOnLastFramesetWaitedUpon() {
        let sender = FakeSender()
        let queue = RMQQueue(name: "great.queue", channelID: 42, sender: sender)

        let method = AMQProtocolBasicGetOk(
            deliveryTag: AMQLonglong(0),
            options: AMQProtocolBasicGetOkOptions.NoOptions,
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr(""),
            messageCount: AMQLong(0)
        )
        let header = AMQContentHeader(classID: 123, bodySize: 321, properties: [])
        let body = AMQContentBody(data: "totally expected message".dataUsingEncoding(NSUTF8StringEncoding)!)

        sender.lastWaitedUponFrameset = AMQFrameset(
            channelID: 42,
            method: method,
            contentHeader: header,
            contentBodies: [body]
        )

        XCTAssertEqual("totally expected message", queue.pop().content)
    }

}
