@objc class ChannelSpyAllocator : NSObject, RMQChannelAllocator {
    var id = 0
    var channels: [ChannelSpy] = []
    
    func allocate() -> RMQChannel {
        let ch = ChannelSpy(id++)
        channels.append(ch)
        return ch
    }

    func releaseChannelNumber(channelNumber: NSNumber!) {
    }
}