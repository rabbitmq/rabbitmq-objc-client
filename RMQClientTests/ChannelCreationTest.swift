import XCTest

class ChannelCreationTest: XCTestCase {
    var conn: RMQConnection?
    var q: QueueHelper?
    var allocator: ChannelSpyAllocator?
    var delegate: ConnectionDelegateSpy?
    var transport: ControlledInteractionTransport?

    override func setUp() {
        super.setUp()

        transport = ControlledInteractionTransport()
        q = QueueHelper()
        delegate = ConnectionDelegateSpy()
        allocator = ChannelSpyAllocator()
        let frameHandler = FrameHandlerSpy()
        conn = RMQConnection(transport: transport!,
                             user: "",
                             password: "",
                             vhost: "",
                             channelMax: 10,
                             frameMax: 2,
                             heartbeat: 3,
                             channelAllocator: allocator!,
                             frameHandler: frameHandler,
                             delegate: delegate!,
                             delegateQueue: q!.dispatchQueue,
                             networkQueue: q!.dispatchQueue)
    }

    func testSendsChannelActivateIfHandshakeIsComplete() {
        conn?.start()
        q?.finish()
        transport?.handshake()
        conn?.createChannel()
        let actualDelegate: ConnectionDelegateSpy = allocator!.channels.last!.delegateSentToActivate! as! ConnectionDelegateSpy
        XCTAssertEqual(delegate!, actualDelegate)
    }

    func testDelaysSendingOfChannelActivateIfHandshakeIsIncomplete() {
        conn?.start()
        q?.finish()
        conn?.createChannel()
        XCTAssertNil(allocator!.channels.last!.delegateSentToActivate)
        transport?.handshake()
        XCTAssertNotNil(allocator!.channels.last!.delegateSentToActivate)
    }

    func testCallsOpenOnChannel() {
        conn!.createChannel()
        q!.finish()

        XCTAssert(allocator!.channels.last!.openCalled)
    }

}
