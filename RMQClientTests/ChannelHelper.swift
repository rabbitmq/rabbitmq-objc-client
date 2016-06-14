class ChannelHelper {

    static func makeChannel(number: Int,
                            contentBodySize: NSNumber = 100,
                            dispatcher: RMQDispatcher = DispatcherSpy(),
                            commandQueue: RMQLocalSerialQueue = FakeSerialQueue(),
                            nameGenerator: RMQNameGenerator = StubNameGenerator(),
                            allocator: RMQChannelAllocator = ChannelSpyAllocator(),
                            confirmations: RMQConfirmations = ConfirmationsSpy()) -> RMQAllocatedChannel {
        return RMQAllocatedChannel(number,
                                   contentBodySize: contentBodySize,
                                   dispatcher: dispatcher,
                                   commandQueue: commandQueue,
                                   nameGenerator: nameGenerator,
                                   allocator: allocator,
                                   confirmations: confirmations)
    }
    
}