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

    func testReinstatesLastSentPrefetchSettings() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.basicQos(2, global: false) // 2 per consumer
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))
        ch.basicQos(3, global: true)  // 3 per channel
        dispatcher.lastSyncMethodHandler!(RMQFrameset(channelNumber: 1, method: MethodFixtures.basicQosOk()))
        dispatcher.syncMethodsSent = []

        ch.recover()

        XCTAssertEqual(MethodFixtures.basicQos(2, options: []), dispatcher.syncMethodsSent[1] as? RMQBasicQos)
        XCTAssertEqual(MethodFixtures.basicQos(3, options: [.Global]), dispatcher.syncMethodsSent[2] as? RMQBasicQos)
    }

    func testDoesNotReinstatePrefetchSettingsIfNoneSet() {
        let dispatcher = DispatcherSpy()
        let ch = RMQAllocatedChannel(1,
                                     contentBodySize: 100,
                                     dispatcher: dispatcher,
                                     commandQueue: FakeSerialQueue(),
                                     nameGenerator: StubNameGenerator(),
                                     allocator: ChannelSpyAllocator())
        ch.recover()

        XCTAssertFalse(dispatcher.syncMethodsSent.contains { $0.isKindOfClass(RMQBasicQos.self) })
    }

}
