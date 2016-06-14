@objc class ConfirmationsSpy : NSObject, RMQConfirmations {
    var lastReceivedCallback: RMQConfirmationCallback?
    var lastReceivedAck: RMQBasicAck?
    var lastReceivedNack: RMQBasicNack?
    var publicationCount = 0
    var _isEnabled = false
    var recoverCalled = false

    func enable() {
        _isEnabled = true
    }

    func isEnabled() -> Bool {
        return _isEnabled
    }

    func recover() {
        recoverCalled = true
    }

    func addPublication() {
        publicationCount += 1
    }

    func addCallback(callback: RMQConfirmationCallback!) {
        lastReceivedCallback = callback
    }

    func ack(ack: RMQBasicAck!) {
        lastReceivedAck = ack
    }

    func nack(nack: RMQBasicNack!) {
        lastReceivedNack = nack
    }
}