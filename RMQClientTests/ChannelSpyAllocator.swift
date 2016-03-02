@objc class ChannelSpyAllocator : NSObject, RMQChannelAllocator {
    var id = 0
    var channels: [ChannelSpy] = []
    
    func allocateWithSender(sender: RMQSender!) -> RMQChannel! {
        let ch = ChannelSpy(id++)
        channels.append(ch)
        return ch
    }
}