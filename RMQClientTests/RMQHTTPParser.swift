import Foundation
import Gloss

public struct RMQHTTPConnection : Decodable {
    public let name: String

    public init?(json: JSON) {
        guard let name: String = "name" <~~ json
            else { return nil }
        self.name = name
    }
}

class RMQHTTPParser {
    func connections(data: NSData) -> [RMQHTTPConnection] {
        var json: [[String: AnyObject]]!
        json = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]]

        return json.map { (item) -> RMQHTTPConnection in
            RMQHTTPConnection(json: item)!
        }
    }
}