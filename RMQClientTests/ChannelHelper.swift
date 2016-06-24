class ChannelHelper {

    static func makeChannel(number: Int,
                            contentBodySize: NSNumber = 100,
                            dispatcher: RMQDispatcher = DispatcherSpy(),
                            recoveryDispatcher: RMQDispatcher = DispatcherSpy(),
                            nameGenerator: RMQNameGenerator = StubNameGenerator(),
                            allocator: RMQChannelAllocator = ChannelSpyAllocator(),
                            confirmations: RMQConfirmations = ConfirmationsSpy()) -> RMQAllocatedChannel {
        return RMQAllocatedChannel(number,
                                   contentBodySize: contentBodySize,
                                   dispatcher: dispatcher,
                                   recoveryDispatcher: recoveryDispatcher,
                                   nameGenerator: nameGenerator,
                                   allocator: allocator,
                                   confirmations: confirmations)
    }
    
}