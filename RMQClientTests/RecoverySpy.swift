@objc class RecoverySpy : NSObject, RMQConnectionRecovery {
    var recoverCalled = false
    
    func recover() {
        recoverCalled = true
    }
}