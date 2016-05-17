import XCTest

class ChannelCreationTest: XCTestCase {
    var conn: RMQConnection?
    var q: FakeSerialQueue?
    var allocator: ChannelSpyAllocator?
    var delegate: ConnectionDelegateSpy?
    var transport: ControlledInteractionTransport?

    override func setUp() {
        super.setUp()

        transport = ControlledInteractionTransport()
        q = FakeSerialQueue()
        delegate = ConnectionDelegateSpy()
        allocator = ChannelSpyAllocator()
        let frameHandler = FrameHandlerSpy()
        conn = RMQConnection(transport: transport!,
                             config: ConnectionHelper.connectionConfig(),
                             handshakeTimeout: 10,
                             channelAllocator: allocator!,
                             frameHandler: frameHandler,
                             delegate: delegate!,
                             commandQueue: q!,
                             waiterFactory: FakeWaiterFactory(),
                             heartbeatSender: HeartbeatSenderSpy())
    }

    func testSendsChannelActivateIfHandshakeIsComplete() {
        conn?.start()
        try! q?.step()
        transport?.handshake()

        conn?.createChannel()

        try! q?.step()

        let actualDelegate: ConnectionDelegateSpy = allocator!.channels.last!.delegateSentToActivate! as! ConnectionDelegateSpy
        XCTAssertEqual(delegate!, actualDelegate)
    }

    func testDelaysSendingOfChannelActivateUntilHandshakeIsComplete() {
        conn?.start()
        conn?.createChannel()

        XCTAssertNil(allocator!.channels.last!.delegateSentToActivate)
        try! q?.step()
        try! q?.step()
        transport?.handshake()
        XCTAssertNotNil(allocator!.channels.last!.delegateSentToActivate)
    }

    func testCallsOpenOnChannel() {
        conn!.createChannel()
        try! q?.step()

        XCTAssert(allocator!.channels.last!.openCalled)
    }

}
