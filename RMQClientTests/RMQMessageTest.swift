import XCTest

class RMQMessageTest: XCTestCase {

    func testPropertiesHaveAssociatedGetters() {
        let date = NSDate()
        var props: [RMQValue] = []
        props.append(RMQBasicAppId("my app ID"))
        props.append(RMQBasicContentType("some/contenttype"))
        props.append(RMQBasicCorrelationId("my correlation ID"))
        props.append(RMQBasicHeaders(["some" : RMQLongstr("header")]))
        props.append(RMQBasicMessageId("my message ID"))
        props.append(RMQBasicType("my type"))
        props.append(RMQBasicPriority(9))
        props.append(RMQBasicReplyTo("my.sender"))
        props.append(RMQBasicTimestamp(date))

        let m = RMQMessage(content: "my message",
                           consumerTag: "ctag",
                           deliveryTag: 1,
                           redelivered: false,
                           exchangeName: "my exchange",
                           routingKey: "my routing key",
                           properties: props)

        let expectedHeaders: [String : NSObject] = ["some" : RMQLongstr("header")]
        XCTAssertEqual("my app ID",         m.appID())
        XCTAssertEqual("some/contenttype",  m.contentType())
        XCTAssertEqual("my correlation ID", m.correlationID())
        XCTAssertEqual(expectedHeaders,     m.headers())
        XCTAssertEqual("my message ID",     m.messageID())
        XCTAssertEqual("my type",           m.messageType())
        XCTAssertEqual(9,                   m.priority())
        XCTAssertEqual("my.sender",         m.replyTo())
        XCTAssertEqual(date,                m.timestamp())
    }

}
