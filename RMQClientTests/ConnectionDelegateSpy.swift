@objc class ConnectionDelegateSpy : NSObject, RMQConnectionDelegate {
    var lastConnectionError = NSError(
        domain: RMQErrorDomain,
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "no error yet"]
    )

    func connection(connection: RMQConnection!, failedToConnectWithError error: NSError!) {
        lastConnectionError = error
    }
}