@objc class StubNameGenerator: NSObject, RMQNameGenerator {
    var nextName = "generated-queue-name-for-test"

    func generateWithPrefix(prefix: String!) -> String! {
        return nextName
    }

}
