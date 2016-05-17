@objc class StubNameGenerator: NSObject, RMQNameGenerator {
    var nextName = "generated-name-for-test"

    func generateWithPrefix(prefix: String!) -> String! {
        return nextName
    }

}
