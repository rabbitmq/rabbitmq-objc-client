import XCTest

class RMQHTTPParserTest: XCTestCase {

    func testParseArrayOfConnectionsWithOneItem() {
        let parser = RMQHTTPParser()
        let connections = parser.connections("[{\"recv_oct\":393,\"recv_oct_details\":{\"rate\":0.0},\"send_oct\":523,\"send_oct_details\":{\"rate\":0.0},\"recv_cnt\":4,\"send_cnt\":3,\"send_pend\":0,\"state\":\"running\",\"channels\":0,\"type\":\"network\",\"node\":\"rabbit@localhost\",\"name\":\"127.0.0.1:53089 -> 127.0.0.1:5672\",\"port\":5672,\"peer_port\":53089,\"host\":\"127.0.0.1\",\"peer_host\":\"127.0.0.1\",\"ssl\":false,\"peer_cert_subject\":null,\"peer_cert_issuer\":null,\"peer_cert_validity\":null,\"auth_mechanism\":\"PLAIN\",\"ssl_protocol\":null,\"ssl_key_exchange\":null,\"ssl_cipher\":null,\"ssl_hash\":null,\"protocol\":\"AMQP 0-9-1\",\"user\":\"guest\",\"vhost\":\"/\",\"timeout\":60,\"frame_max\":131072,\"channel_max\":65535,\"client_properties\":{\"capabilities\":{\"publisher_confirms\":true,\"consumer_cancel_notify\":true,\"exchange_exchange_bindings\":true,\"basic.nack\":true,\"connection.blocked\":true,\"authentication_failure_close\":true},\"product\":\"Bunny\",\"platform\":\"ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin14]\",\"version\":\"2.2.2\",\"information\":\"http://rubybunny.info\"},\"connected_at\":1462958634765}]".dataUsingEncoding(NSUTF8StringEncoding)!)
        XCTAssertEqual("127.0.0.1:53089 -> 127.0.0.1:5672", connections[0].name)
    }

}
