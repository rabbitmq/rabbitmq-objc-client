class BasicPropertyFixtures {
    static func exhaustiveHeadersDict() -> [String: RMQValue] {
        let mytime = NSDate.distantFuture()
        let subTable: [String: RMQValue] = [
            "sub": RMQLongstr("headers"),
            "4": RMQSignedLonglong(2)
        ]
        let array: [RMQSignedLonglong] = [
            RMQSignedLonglong(5),
            RMQSignedLonglong(4),
            RMQSignedLonglong(3)
        ]
        let headers: [String: RMQValue] = [
            "arbitrary": RMQLongstr("string"),
            "a-number": RMQSignedLonglong(-2),
            "moar": RMQTable(subTable),
            "an-array": RMQArray(array),
            "mytime": RMQTimestamp(mytime),
            "onbool": RMQBoolean(true),
            "offbool": RMQBoolean(false),
            "nilly": RMQVoid()
        ]
        return headers
    }

    static func exhaustiveHeaders() -> RMQBasicHeaders {
        return RMQBasicHeaders(exhaustiveHeadersDict())
    }
}