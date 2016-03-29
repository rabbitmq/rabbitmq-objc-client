import XCTest

class RMQChannelContract {
    var ch: RMQChannel

    init(_ channel: RMQChannel) {
        ch = channel
    }
    
    func canInstantiateAQueueThatHoldsItsName() -> RMQChannelContract {
        let q = ch.queue("some name", options: [])
        XCTAssertEqual("some name", q.name)
        return self
    }

    func cachesQueuesWithSameName() -> RMQChannelContract {
        let q = ch.queue("my name", options: [])
        XCTAssert(q === ch.queue("my name", options: [.AutoDelete, .Exclusive]), "queue not same cached object")
        return self
    }

    func doesNotCacheQueuesWithDifferentNames() -> RMQChannelContract {
        let q = ch.queue("my name1", options: [])
        XCTAssertNotEqual(q, ch.queue("my name2", options: []))
        return self
    }

    func check() {
        canInstantiateAQueueThatHoldsItsName()
            .cachesQueuesWithSameName()
            .doesNotCacheQueuesWithDifferentNames()
    }

}
