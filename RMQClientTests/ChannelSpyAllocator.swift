@objc class ChannelSpyAllocator : NSObject, RMQChannelAllocator {
    var id = 0
    var channels: [ChannelSpy] = []
    var sender: RMQSender!
    
    func allocate() -> RMQChannel {
        let ch = ChannelSpy(id)
        id += 1
        channels.append(ch)
        return ch
    }

    func releaseChannelNumber(channelNumber: NSNumber!) {
        channels = channels.filter { ch -> Bool in
            ch.channelNumber != channelNumber
        }
    }

    func allocatedUserChannels() -> [RMQChannel]! {
        return Array(channels.dropFirst(1).sort { $0.channelNumber.integerValue < $1.channelNumber.integerValue })
    }
}