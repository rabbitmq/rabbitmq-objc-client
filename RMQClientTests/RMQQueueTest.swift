import XCTest

class RMQQueueTest: XCTestCase {

    func testPublishSendsABasicPublish() {
        let sender = SenderSpy(frameMax: 4)
        let queue = RMQQueue(name: "my.q", channelID: 123, sender: sender)
        let messageContent = "my great message yo"

        queue.publish(messageContent)

        let publish = AMQProtocolBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("my.q"),
            options: AMQProtocolBasicPublishOptions.NoOptions
        )
        let expectedBodyData = messageContent.dataUsingEncoding(NSUTF8StringEncoding)!

        let persistent = AMQBasicDeliveryMode(2)
        let contentTypeOctetStream = AMQBasicContentType("application/octet-stream")
        let lowPriority = AMQBasicPriority(0)

        let expectedHeader = AMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.length,
            properties: [persistent, contentTypeOctetStream, lowPriority]
        )

        let expectedBodies = [
            AMQContentBody(data: "my g".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "reat".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: " mes".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "sage".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: " yo".dataUsingEncoding(NSUTF8StringEncoding)!),
        ]

        let expectedFrameset = AMQFrameset(
            channelID: 123,
            method: publish,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        XCTAssertEqual(5, sender.lastSentFrameset.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.lastSentFrameset.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.lastSentFrameset)
    }

    func testPublishWhenContentLengthIsMultipleOfFrameMax() {
        let sender = SenderSpy(frameMax: 4)
        let queue = RMQQueue(name: "my.q", channelID: 123, sender: sender)
        let messageContent = "12345678"

        queue.publish(messageContent)

        let expectedMethod = AMQProtocolBasicPublish(
            reserved1: AMQShort(0),
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr("my.q"),
            options: AMQProtocolBasicPublishOptions.NoOptions
        )

        let expectedBodyData = messageContent.dataUsingEncoding(NSUTF8StringEncoding)!
        let persistent = AMQBasicDeliveryMode(2)
        let contentTypeOctetStream = AMQBasicContentType("application/octet-stream")
        let lowPriority = AMQBasicPriority(0)

        let expectedHeader = AMQContentHeader(
            classID: 60,
            bodySize: expectedBodyData.length,
            properties: [persistent, contentTypeOctetStream, lowPriority]
        )

        let expectedBodies = [
            AMQContentBody(data: "1234".dataUsingEncoding(NSUTF8StringEncoding)!),
            AMQContentBody(data: "5678".dataUsingEncoding(NSUTF8StringEncoding)!),
        ]

        let expectedFrameset = AMQFrameset(
            channelID: 123,
            method: expectedMethod,
            contentHeader: expectedHeader,
            contentBodies: expectedBodies
        )

        XCTAssertEqual(2, sender.lastSentFrameset.contentBodies.count)
        XCTAssertEqual(expectedBodies, sender.lastSentFrameset.contentBodies)
        XCTAssertEqual(expectedFrameset, sender.lastSentFrameset)
    }
    
    func testPopSendsAGet() {
        let sender = SenderSpy()
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
        let sender = SenderSpy()
        let queue = RMQQueue(name: "great.queue", channelID: 42, sender: sender)

        queue.pop()

        XCTAssertEqual("AMQProtocolBasicGetOk", sender.methodWaitedUpon)
        XCTAssertEqual(42, sender.channelWaitedUpon)
    }

    func testPopReturnsMessageBasedOnLastFramesetWaitedUpon() {
        let sender = SenderSpy()
        let queue = RMQQueue(name: "great.queue", channelID: 42, sender: sender)

        let method = AMQProtocolBasicGetOk(
            deliveryTag: AMQLonglong(0),
            options: AMQProtocolBasicGetOkOptions.NoOptions,
            exchange: AMQShortstr(""),
            routingKey: AMQShortstr(""),
            messageCount: AMQLong(0)
        )
        let header = AMQContentHeader(classID: 123, bodySize: 321, properties: [])
        let body1 = AMQContentBody(data: "totally expected ".dataUsingEncoding(NSUTF8StringEncoding)!)
        let body2 = AMQContentBody(data: "message".dataUsingEncoding(NSUTF8StringEncoding)!)

        sender.lastWaitedUponFrameset = AMQFrameset(
            channelID: 42,
            method: method,
            contentHeader: header,
            contentBodies: [body1, body2]
        )

        XCTAssertEqual("totally expected message", queue.pop().content)
    }

}
