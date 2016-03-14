import XCTest

class RMQChannelContract {
    var ch: RMQChannel

    init(_ channel: RMQChannel) {
        ch = channel
    }
    
    func canInstantiateAQueueThatHoldsItsName() -> RMQChannelContract {
        let q = ch.queue("some name", autoDelete: false, exclusive: false)
        XCTAssertEqual("some name", q.name)
        return self
    }

    func cachesQueuesWithSameName() -> RMQChannelContract {
        let q = ch.queue("my name", autoDelete: false, exclusive: false)
        XCTAssert(q === ch.queue("my name", autoDelete: true, exclusive: true), "queue not same cached object")
        return self
    }

    func doesNotCacheQueuesWithDifferentNames() -> RMQChannelContract {
        let q = ch.queue("my name1", autoDelete: false, exclusive: false)
        XCTAssertNotEqual(q, ch.queue("my name2", autoDelete: false, exclusive: false))
        return self
    }

    func check() {
        canInstantiateAQueueThatHoldsItsName()
            .cachesQueuesWithSameName()
            .doesNotCacheQueuesWithDifferentNames()
    }

}
