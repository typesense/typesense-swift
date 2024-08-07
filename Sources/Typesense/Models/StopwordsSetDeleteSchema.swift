import Foundation



public struct StopwordsSetDeleteSchema: Codable {
    public var _id: String

    public init(_id: String) {
        self._id = _id
    }

    public enum CodingKeys: String, CodingKey {
        case _id = "id"
    }

}
