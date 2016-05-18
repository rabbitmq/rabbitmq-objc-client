import XCTest

class ChannelRecoveryTest: XCTestCase {

    func testReopensChannel() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.recover()

        XCTAssertEqual(MethodFixtures.channelOpen(), dispatcher.syncMethodsSent[0] as? RMQChannelOpen)
    }

    func testReinstatesLastSentPrefetchSetting() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.basicQos(2, global: false)
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))
        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssertEqual(MethodFixtures.basicQos(2, options: [.Global]), dispatcher.syncMethodsSent[1] as? RMQBasicQos)
    }

}
